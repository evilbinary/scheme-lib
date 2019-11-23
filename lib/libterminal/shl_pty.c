/*
 * SHL - PTY Helpers
 *
 * Copyright (c) 2011-2013 David Herrmann <dh.herrmann@gmail.com>
 * Dedicated to the Public Domain
 */

/*
 * PTY Helpers
 */

#include <errno.h>
#include <fcntl.h>
#include <limits.h>

#ifdef __APPLE__
#include <util.h>
#else 
	#include <pty.h>
#endif 

#include <signal.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef USE_EPOLL
	#include <sys/epoll.h>
#endif
#include <sys/ioctl.h>
#include <sys/uio.h>
#include <termios.h>
#include <unistd.h>
#include "shl_pty.h"


#ifndef SIGUNUSED
#define SIGUNUSED SIGSYS
#endif

#define SHL_PTY_BUFSIZE 16384

/*
 * Ring Buffer
 * Our PTY helper buffers outgoing data so the caller can rely on write
 * operations to always succeed (except for OOM). To buffer data in a PTY we
 * use a fast ring buffer to avoid heavy re-allocations on every write.
 *
 * Note that this allows users to use pty-writes for small data without
 * causing heavy allocations in the PTY layer. This is quite important for
 * keyboard-handling or other DEC-VT emulations.
 */

struct ring {
	char *buf;
	size_t size;
	size_t start;
	size_t end;
};

#define RING_MASK(_r, _v) ((_v) & ((_r)->size - 1))

/*
 * Resize ring-buffer to size @nsize. @nsize must be a power-of-2, otherwise
 * ring operations will behave incorrectly.
 */
static int ring_resize(struct ring *r, size_t nsize)
{
	char *buf;

	buf = malloc(nsize);
	if (!buf)
		return -ENOMEM;

	if (r->end == r->start) {
		r->end = 0;
		r->start = 0;
	} else if (r->end > r->start) {
		memcpy(buf, &r->buf[r->start], r->end - r->start);

		r->end -= r->start;
		r->start = 0;
	} else {
		memcpy(buf, &r->buf[r->start], r->size - r->start);
		memcpy(&buf[r->size - r->start], r->buf, r->end);

		r->end += r->size - r->start;
		r->start = 0;
	}

	free(r->buf);
	r->buf = buf;
	r->size = nsize;

	return 0;
}

/* Compute next higher power-of-2 of @v. Returns 4096 in case v is 0. */
static size_t ring_pow2(size_t v)
{
	size_t i;

	if (!v)
		return 4096;

	--v;

	for (i = 1; i < 8 * sizeof(size_t); i *= 2)
		v |= v >> i;

	return ++v;
}

/*
 * Resize ring-buffer to provide enough room for @add bytes of new data. This
 * resizes the buffer if it is too small. It returns -ENOMEM on OOM and 0 on
 * success.
 */
static int ring_grow(struct ring *r, size_t add)
{
	size_t len;

	/*
	 * Note that "end == start" means "empty buffer". Hence, we can never
	 * fill the last byte of a buffer. That means, we must account for an
	 * additional byte here ("end == start"-byte).
	 */

	if (r->end < r->start)
		len = r->start - r->end;
	else
		len = r->start + r->size - r->end;

	/* don't use ">=" as "end == start" would be ambigious */
	if (len > add)
		return 0;

	/* +1 for additional "end == start" byte */
	len = r->size + add - len + 1;
	len = ring_pow2(len);

	if (len <= r->size)
		return -ENOMEM;

	return ring_resize(r, len);
}

/*
 * Push @len bytes from @u8 into the ring buffer. The buffer is resized if it
 * is too small. -ENOMEM is returned on OOM, 0 on success.
 */
static int ring_push(struct ring *r, const char *u8, size_t len)
{
	int err;
	size_t l;

	err = ring_grow(r, len);
	if (err < 0)
		return err;

	if (r->start <= r->end) {
		l = r->size - r->end;
		if (l > len)
			l = len;

		memcpy(&r->buf[r->end], u8, l);
		r->end = RING_MASK(r, r->end + l);

		len -= l;
		u8 += l;
	}

	if (!len)
		return 0;

	memcpy(&r->buf[r->end], u8, len);
	r->end = RING_MASK(r, r->end + len);

	return 0;
}

/*
 * Get data pointers for current ring-buffer data. @vec must be an array of 2
 * iovec objects. They are filled according to the data available in the
 * ring-buffer. 0, 1 or 2 is returned according to the number of iovec objects
 * that were filled (0 meaning buffer is empty).
 *
 * Hint: "struct iovec" is defined in <sys/uio.h> and looks like this:
 *     struct iovec {
 *         void *iov_base;
 *         size_t iov_len;
 *     };
 */
static size_t ring_peek(struct ring *r, struct iovec *vec)
{
	if (r->end > r->start) {
		vec[0].iov_base = &r->buf[r->start];
		vec[0].iov_len = r->end - r->start;
		return 1;
	} else if (r->end < r->start) {
		vec[0].iov_base = &r->buf[r->start];
		vec[0].iov_len = r->size - r->start;
		vec[1].iov_base = r->buf;
		vec[1].iov_len = r->end;
		return r->end ? 2 : 1;
	} else {
		return 0;
	}
}

/*
 * Remove @len bytes from the start of the ring-buffer. Note that we protect
 * against overflows so removing more bytes than available is safe.
 */
static void ring_pop(struct ring *r, size_t len)
{
	size_t l;

	if (r->start > r->end) {
		l = r->size - r->start;
		if (l > len)
			l = len;

		r->start = RING_MASK(r, r->start + l);
		len -= l;
	}

	if (!len)
		return;

	l = r->end - r->start;
	if (l > len)
		l = len;

	r->start = RING_MASK(r, r->start + l);
}

/*
 * PTY
 * A PTY object represents a single PTY connection between a master and a
 * child. The child process is fork()ed so the caller controls what program
 * will be run.
 *
 * Programs like /bin/login tend to perform a vhangup() on their TTY
 * before running the login procedure. This also causes the pty master
 * to get a EPOLLHUP event as long as no client has the TTY opened.
 * This means, we cannot use the TTY connection as reliable way to track
 * the client. Instead, we _must_ rely on the PID of the client to track
 * them.
 * However, this has the side effect that if the client forks and the
 * parent exits, we loose them and restart the client. But this seems to
 * be the expected behavior so we implement it here.
 *
 * Unfortunately, epoll always polls for EPOLLHUP so as long as the
 * vhangup() is ongoing, we will _always_ get EPOLLHUP and cannot sleep.
 * This gets worse if the client closes the TTY but doesn't exit.
 * Therefore, we the fd must be edge-triggered in the epoll-set so we
 * only get the events once they change. This has to be taken into by the
 * user of shl_pty. As many event-loops don't support edge-triggered
 * behavior, you can use the shl_pty_bridge interface.
 *
 * Note that shl_pty does not track SIGHUP, you need to do that yourself
 * and call shl_pty_close() once the client exited.
 */

struct shl_pty {
	unsigned long ref;
	int fd;
	pid_t child;
	char in_buf[SHL_PTY_BUFSIZE];
	struct ring out_buf;

	shl_pty_input_cb cb;
	void *data;
};

enum shl_pty_msg {
	SHL_PTY_FAILED,
	SHL_PTY_SETUP,
};

static char pty_recv(int fd)
{
	int r;
	char d;

	do {
		r = read(fd, &d, 1);
	} while (r < 0 && (errno == EINTR || errno == EAGAIN));

	return (r <= 0) ? SHL_PTY_FAILED : d;
}

static int pty_send(int fd, char d)
{
	int r;

	do {
		r = write(fd, &d, 1);
	} while (r < 0 && (errno == EINTR || errno == EAGAIN));

	return (r == 1) ? 0 : -EINVAL;
}

static int pty_setup_child(int slave,
			   unsigned short term_width,
			   unsigned short term_height)
{
	struct termios attr;
	struct winsize ws;

	/* get terminal attributes */
	if (tcgetattr(slave, &attr) < 0)
		return -errno;

	/* erase character should be normal backspace, PLEASEEE! */
	attr.c_cc[VERASE] = 010;

	/* set changed terminal attributes */
	if (tcsetattr(slave, TCSANOW, &attr) < 0)
		return -errno;

	memset(&ws, 0, sizeof(ws));
	ws.ws_col = term_width;
	ws.ws_row = term_height;

	if (ioctl(slave, TIOCSWINSZ, &ws) < 0)
		return -errno;

	if (dup2(slave, STDIN_FILENO) != STDIN_FILENO ||
	    dup2(slave, STDOUT_FILENO) != STDOUT_FILENO ||
	    dup2(slave, STDERR_FILENO) != STDERR_FILENO)
		return -errno;

	return 0;
}

static int pty_init_child(int fd)
{
	int r;
	sigset_t sigset;
	char *slave_name;
	int slave, i;
	pid_t pid;

	/* unlockpt() requires unset signal-handlers */
	sigemptyset(&sigset);
	r = sigprocmask(SIG_SETMASK, &sigset, NULL);
	if (r < 0)
		return -errno;

	for (i = 1; i < SIGUNUSED; ++i)
		signal(i, SIG_DFL);

	r = grantpt(fd);
	if (r < 0)
		return -errno;

	r = unlockpt(fd);
	if (r < 0)
		return -errno;

	slave_name = ptsname(fd);
	if (!slave_name)
		return -errno;

	/* open slave-TTY */
	slave = open(slave_name, O_RDWR | O_CLOEXEC | O_NOCTTY);
	if (slave < 0)
		return -errno;

	/* open session so we loose our controlling TTY */
	pid = setsid();
	if (pid < 0) {
		close(slave);
		return -errno;
	}

	/* set controlling TTY */
	r = ioctl(slave, TIOCSCTTY, 0);
	if (r < 0) {
		close(slave);
		return -errno;
	}

	return slave;
}

pid_t shl_pty_open(struct shl_pty **out,
		   shl_pty_input_cb cb,
		   void *data,
		   unsigned short term_width,
		   unsigned short term_height)
{
	struct shl_pty *pty;
	pid_t pid;
	int fd, comm[2], slave, r;
	char d;

	pty = calloc(1, sizeof(*pty));
	if (!pty)
		return -ENOMEM;

	fd = posix_openpt(O_RDWR | O_NOCTTY | O_CLOEXEC | O_NONBLOCK);
	if (fd < 0) {
		free(pty);
		return -errno;
	}

	r = pipe(comm); //pipe2(comm, O_CLOEXEC)
	if (r < 0) {
		r = -errno;
		close(fd);
		free(pty);
		return r;
	}

	pid = fork();
	if (pid < 0) {
		/* error */
		pid = -errno;
		close(comm[0]);
		close(comm[1]);
		close(fd);
		free(pty);
		return pid;
	} else if (!pid) {
		/* child */
		close(comm[0]);
		free(pty);

		slave = pty_init_child(fd);
		close(fd);

		if (slave < 0)
			exit(1);

		r = pty_setup_child(slave, term_width, term_height);
		if (r < 0)
			exit(1);

		/* close slave if it's not one of the std-fds */
		if (slave > 2)
			close(slave);

		/* wake parent */
		pty_send(comm[1], SHL_PTY_SETUP);
		close(comm[1]);

		*out = NULL;
		return pid;
	}

	/* parent */
	close(comm[1]);

	pty->ref = 1;
	pty->fd = fd;
	pty->child = pid;
	pty->cb = cb;
	pty->data = data;

	/* wait for child setup */
	d = pty_recv(comm[0]);
	if (d != SHL_PTY_SETUP) {
		close(comm[0]);
		close(fd);
		free(pty);
		return -EINVAL;
	}

	close(comm[0]);
	*out = pty;
	return pid;
}

void shl_pty_ref(struct shl_pty *pty)
{
	if (!pty || !pty->ref)
		return;

	++pty->ref;
}

void shl_pty_unref(struct shl_pty *pty)
{
	if (!pty || !pty->ref || --pty->ref)
		return;

	shl_pty_close(pty);
	free(pty->out_buf.buf);
	free(pty);
}

void shl_pty_close(struct shl_pty *pty)
{
	if (pty->fd < 0)
		return;

	close(pty->fd);
	pty->fd = -1;
}

bool shl_pty_is_open(struct shl_pty *pty)
{
	return pty->fd >= 0;
}

int shl_pty_get_fd(struct shl_pty *pty)
{
	return pty->fd;
}

pid_t shl_pty_get_child(struct shl_pty *pty)
{
	return pty->child;
}

static void pty_write(struct shl_pty *pty)
{
	struct iovec vec[2];
	size_t num;
	ssize_t r;

	num = ring_peek(&pty->out_buf, vec);
	if (!num)
		return;

	/* ignore errors in favor of SIGCHLD; (we're edge-triggered, anyway) */
	r = writev(pty->fd, vec, (int)num);
	if (r >= 0)
		ring_pop(&pty->out_buf, (size_t)r);
}

static int pty_read(struct shl_pty *pty)
{
	ssize_t len, num;

	/* We're edge-triggered, means we need to read the whole queue. This,
	 * however, might cause us to stall if the writer is faster than we
	 * are. Therefore, we have some rather arbitrary limit on how fast
	 * we read. If we reach it, we simply return EAGAIN to the caller and
	 * let them deal with it. */
	num = 50;
	do {
		len = read(pty->fd, pty->in_buf, sizeof(pty->in_buf));
		if (len > 0)
			pty->cb(pty, pty->in_buf, len, pty->data);
	} while (len > 0 && --num);

	return !num ? -EAGAIN : 0;
}

int shl_pty_dispatch(struct shl_pty *pty)
{
	int r;

	r = pty_read(pty);
	pty_write(pty);
	return r;
}

int shl_pty_write(struct shl_pty *pty, const char *u8, size_t len)
{
	if (!shl_pty_is_open(pty))
		return -ENODEV;

	return ring_push(&pty->out_buf, u8, len);
}

int shl_pty_signal(struct shl_pty *pty, int sig)
{
	int r;

	if (!shl_pty_is_open(pty))
		return -ENODEV;

	r = ioctl(pty->fd, TIOCSIG, sig);
	return (r < 0) ? -errno : 0;
}

int shl_pty_resize(struct shl_pty *pty,
		   unsigned short term_width,
		   unsigned short term_height)
{
	struct winsize ws;
	int r;

	if (!shl_pty_is_open(pty))
		return -ENODEV;

	memset(&ws, 0, sizeof(ws));
	ws.ws_col = term_width;
	ws.ws_row = term_height;

	/*
	 * This will send SIGWINCH to the pty slave foreground process group.
	 * We will also get one, but we don't need it.
	 */
	r = ioctl(pty->fd, TIOCSWINSZ, &ws);
	return (r < 0) ? -errno : 0;
}

/*
 * PTY Bridge
 * The PTY bridge wraps multiple ptys in a single file-descriptor. It is
 * enough for the caller to listen for read-events on the fd.
 *
 * This interface is provided to allow integration of PTYs into event-loops
 * that do not support edge-triggered interfaces. There is no other reason
 * to use this bridge.
 */
#ifdef USE_EPOLL
int shl_pty_bridge_new(void)
{
	int fd;

	fd = epoll_create1(EPOLL_CLOEXEC);
	if (fd < 0)
		return -errno;

	return fd;
}

void shl_pty_bridge_free(int bridge)
{
	close(bridge);
}

int shl_pty_bridge_dispatch(int bridge, int timeout)
{
	struct epoll_event up, ev;
	struct shl_pty *pty;
	int fd, r;

	r = epoll_wait(bridge, &ev, 1, timeout);
	if (r < 0) {
		if (errno == EAGAIN || errno == EINTR)
			return 0;

		return -errno;
	}

	if (!r)
		return 0;

	pty = ev.data.ptr;
	r = shl_pty_dispatch(pty);
	if (r == -EAGAIN) {
		/* EAGAIN means we couldn't dispatch data fast enough. Modify
		 * the fd in the epoll-set so we get edge-triggered events
		 * next round. */
		memset(&up, 0, sizeof(up));
		up.events = EPOLLIN | EPOLLOUT | EPOLLET;
		up.data.ptr = pty;
		fd = shl_pty_get_fd(pty);
		epoll_ctl(bridge, EPOLL_CTL_ADD, fd, &up);
	}

	return 0;
}

int shl_pty_bridge_add(int bridge, struct shl_pty *pty)
{
	struct epoll_event ev;
	int r, fd;

	memset(&ev, 0, sizeof(ev));
	ev.events = EPOLLIN | EPOLLOUT | EPOLLET;
	ev.data.ptr = pty;
	fd = shl_pty_get_fd(pty);

	r = epoll_ctl(bridge, EPOLL_CTL_ADD, fd, &ev);
	if (r < 0)
		return -errno;

	return 0;
}

void shl_pty_bridge_remove(int bridge, struct shl_pty *pty)
{
	int fd;

	fd = shl_pty_get_fd(pty);
	epoll_ctl(bridge, EPOLL_CTL_DEL, fd, NULL);
}
#endif