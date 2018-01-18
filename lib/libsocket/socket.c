#ifdef WIN32
#include <winsock2.h>
#include <winsock.h>
#include <ws2tcpip.h>
#include <stdint.h>
#include <sys/types.h>
#define in_addr_t uint32_t
#else
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/ioctl.h>
#include<netinet/in.h>
#include <unistd.h>
#endif

#include <string.h>
#include <errno.h>
#include <signal.h>

#include <stdio.h>





#define __socketcall 

uint32_t _ntohl(uint32_t netlong){
  return ntohl(netlong);
}

in_addr_t _inet_addr(const char* strptr){
  return inet_addr(strptr);
}

void* make_sockaddr_in(int family,int addr,int port){
  struct sockaddr_in* addr_in=malloc(sizeof(struct sockaddr_in));
  memset(addr_in, 0, sizeof(struct sockaddr_in));  
  addr_in->sin_family = family;  
  addr_in->sin_addr.s_addr = htonl(addr);//IP地址设置成INADDR_ANY,让系统自动获取本机的IP地址。  
  addr_in->sin_port = htons(port);//设置的端口为DEFAULT_PORT
  //printf("struct sockaddr_in=%d\n",sizeof(struct sockaddr_in));


  
  return addr_in;
}
int _close(int fd){
  return close(fd);
}
 size_t
 _strlen(const char *s){
   return strlen(s);
 }

 ssize_t
 _read(int fildes, void *buf, size_t nbyte){
   //printf("read=>%c nbyte=%d\n",*(char*)buf,nbyte);
#ifdef WIN32
   return recv(fildes,buf,nbyte,0);
  #else
   return read(fildes,buf,nbyte);
#endif
 }


ssize_t
_write_all(int fd, const char *buf,size_t  nbyte){
  
  ssize_t i, m;
  //printf("content %d=>%s\n",nbyte,buf,strlen((char*)buf));
    //printf("len at %s\n",(char*)&buf[nbyte]);
  //nbyte=strlen(buf)-1;
  //printf("len===>%d\n",nbyte);
  
    m = nbyte;
    while (m > 0) {
      #ifdef WIN32
      if ((i = send(fd, buf, m,0)) < 0) { 
      #else
      if ((i = write(fd, buf, m)) < 0) {
	  #endif
            if (errno != EAGAIN && errno != EINTR)
                return i;
        } else {
            m -= i;
            buf += i;
        }
      //printf("i=>%d\n",i);
	      
    }
    return nbyte;
    
    //return write(fildes,buf,nbyte);
}

ssize_t
_write(int fd, const char *buf, size_t nbyte){
     

  ssize_t i, m;
  //printf("content %d=>%s\n",nbyte,buf,strlen((char*)buf));
    //printf("len at %s\n",(char*)&buf[nbyte]);
  fflush(stdout);  
    m = nbyte;
    while (m > 0) {
#ifdef WIN32
      if ((i = send(fd, buf, m,0)) < 0) {
#else
        if ((i = write(fd, buf, m)) < 0) {
#endif
	  if (errno != EAGAIN && errno != EINTR)
	    return i;
        } else {
            m -= i;
            buf += i;
        }
	//printf("i=>%d\n",i);
	      
    }
    return nbyte;


    
    //return write(fildes,buf,nbyte);
}

FILE * _fdopen(int fildes, const char *mode){
  return fdopen(fildes,mode);
}

int     _accept(int socket, struct sockaddr *address,
	       socklen_t *address_len){
  return accept(socket,address,address_len);
}
int     _bind(int socket, const struct sockaddr *address,
             socklen_t address_len){
  return bind(socket,address,address_len);
}
int     _connect(int socket, const struct sockaddr *address,
		socklen_t address_len){
  return connect(socket,address,address_len);
}
int     _getpeername(int socket, struct sockaddr *address,
		    socklen_t *address_len){
  return getpeername(socket,address,address_len);
}
int     _getsockname(int socket, struct sockaddr *address,
		    socklen_t *address_len){
  return getsockname(socket,address,address_len);
}
int     _getsockopt(int socket, int level, int option_name,
		   void *option_value, socklen_t *option_len){
  return getsockopt(socket,level,option_name,option_value,option_len);
  
}
int     _listen(int socket, int backlog){
  return listen(socket,backlog);
}
ssize_t _recv(int socket, void *buffer, size_t length, int flags){
  return recv(socket, buffer,length,flags);
}
ssize_t _recvfrom(int socket, void *buffer, size_t length,
		 int flags, struct sockaddr *address, socklen_t *address_len){
  return  recvfrom( socket,buffer, length,
		    flags, address, address_len);
}
ssize_t _recvmsg(int socket, struct msghdr *message, int flags){
  #ifdef WIN32

  #else
  return  recvmsg( socket,message, flags);
  #endif
}
ssize_t _send(int socket, const void *message, size_t length, int flags){
  return  send( socket, message,length,flags);
}
ssize_t _sendmsg(int socket, const struct msghdr *message, int flags){
  #ifdef WIN32
  #else
  return  sendmsg( socket, message,flags);
#endif
}
ssize_t _sendto(int socket, const void *message, size_t length, int flags,
	       const struct sockaddr *dest_addr, socklen_t dest_len){
  return sendto(socket,message, length,flags,
		dest_addr, dest_len);
}
int     _setsockopt(int socket, int level, int option_name,
		   const void *option_value, socklen_t option_len){
  return  setsockopt(socket,level,option_name,
		     option_value,option_len);
}
int     _shutdown(int socket, int how){
  #ifdef WIN32
    WSACleanup();
    #endif
  return shutdown(socket,how);
}
int     _socket(int domain, int type, int protocol){
#ifdef WIN32
   WSADATA wsadata;
  if(WSAStartup(MAKEWORD(1,1),&wsadata)==SOCKET_ERROR)
  {
    printf("WSAStartup() fail\n");
    exit(0);
  }
#endif
  return socket(domain,type,protocol);
}
int     _socketpair(int domain, int type, int protocol,
		   int socket_vector[2]){
    #ifdef WIN32
  #else
  return socketpair(domain,type,protocol,socket_vector);
  #endif
}
