;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;作者:evilbinary on 2017-12-03 13:56:41.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (thread thread-ffi )
  (export pthread-attr-destroy
  pthread-attr-getdetachstate
  pthread-attr-getguardsize
  pthread-attr-getinheritsched
  pthread-attr-getschedparam
  pthread-attr-getschedpolicy
  pthread-attr-getscope
  pthread-attr-getstackaddr
  pthread-attr-getstacksize
  pthread-attr-init
  pthread-attr-setdetachstate
  pthread-attr-setguardsize
  pthread-attr-setinheritsched
  pthread-attr-setschedparam
  pthread-attr-setschedpolicy
  pthread-attr-setscope
  pthread-attr-setstackaddr
  pthread-attr-setstacksize
  pthread-cancel
  pthread-cleanup-push
  pthread-cleanup-pop
  pthread-cond-broadcast
  pthread-cond-destroy
  pthread-cond-init
  pthread-cond-signal
  pthread-cond-timedwait
  pthread-cond-wait
  pthread-condattr-destroy
  pthread-condattr-getpshared
  pthread-condattr-init
  pthread-condattr-setpshared
  pthread-create
  pthread-detach
  pthread-equal
  pthread-exit
  pthread-getconcurrency
  pthread-getschedparam
  pthread-getspecific
  pthread-join
  pthread-key-create
  pthread-key-delete
  pthread-mutex-destroy
  pthread-mutex-getprioceiling
  pthread-mutex-init
  pthread-mutex-lock
  pthread-mutex-setprioceiling
  pthread-mutex-trylock
  pthread-mutex-unlock
  pthread-mutexattr-destroy
  pthread-mutexattr-getprioceiling
  pthread-mutexattr-getprotocol
  pthread-mutexattr-getpshared
  pthread-mutexattr-gettype
  pthread-mutexattr-init
  pthread-mutexattr-setprioceiling
  pthread-mutexattr-setprotocol
  pthread-mutexattr-setpshared
  pthread-mutexattr-settype
  pthread-once
  pthread-rwlock-destroy
  pthread-rwlock-init
  pthread-rwlock-rdlock
  pthread-rwlock-tryrdlock
  pthread-rwlock-trywrlock
  pthread-rwlock-unlock
  pthread-rwlock-wrlock
  pthread-rwlockattr-destroy
  pthread-rwlockattr-getpshared
  pthread-rwlockattr-init
  pthread-rwlockattr-setpshared
  pthread-self
  pthread-setcancelstate
  pthread-setcanceltype
  pthread-setconcurrency
  pthread-setschedparam
  pthread-setspecific
  pthread-testcancel)

 (import (scheme) (utils libutil) (cffi cffi) )

 (define lib-name
  (case (machine-type)
   ((arm32le) "libthread.so")
   ((a6nt i3nt ta6nt ti3nt) "libthread.dll")
   ((a6osx i3osx ta6osx ti3osx)  "libthread.so")
   ((a6le i3le ta6le ti3le) "libthread.so")))
 (define lib (load-librarys  lib-name ))

;;int pthread_attr_destroy(pthread_attr_t* )
(def-function pthread-attr-destroy
             "c_pthread_attr_destroy" (void*) int)

;;int pthread_attr_getdetachstate(pthread_attr_t*  ,int* )
(def-function pthread-attr-getdetachstate
             "c_pthread_attr_getdetachstate" (void* void*) int)

;;int pthread_attr_getguardsize(pthread_attr_t*  ,size_t* )
(def-function pthread-attr-getguardsize
             "c_pthread_attr_getguardsize" (void* void*) int)

;;int pthread_attr_getinheritsched(pthread_attr_t*  ,int* )
(def-function pthread-attr-getinheritsched
             "c_pthread_attr_getinheritsched" (void* void*) int)

;;int pthread_attr_getschedparam(pthread_attr_t*  ,struct sched_param* )
(def-function pthread-attr-getschedparam
             "c_pthread_attr_getschedparam" (void* void*) int)

;;int pthread_attr_getschedpolicy(pthread_attr_t*  ,int* )
(def-function pthread-attr-getschedpolicy
             "c_pthread_attr_getschedpolicy" (void* void*) int)

;;int pthread_attr_getscope(pthread_attr_t*  ,int* )
(def-function pthread-attr-getscope
             "c_pthread_attr_getscope" (void* void*) int)

;;int pthread_attr_getstackaddr(pthread_attr_t*  ,void )
(def-function pthread-attr-getstackaddr
             "c_pthread_attr_getstackaddr" (void* void) int)

;;int pthread_attr_getstacksize(pthread_attr_t*  ,size_t* )
(def-function pthread-attr-getstacksize
             "c_pthread_attr_getstacksize" (void* void*) int)

;;int pthread_attr_init(pthread_attr_t* )
(def-function pthread-attr-init
             "c_pthread_attr_init" (void*) int)

;;int pthread_attr_setdetachstate(pthread_attr_t*  ,int )
(def-function pthread-attr-setdetachstate
             "c_pthread_attr_setdetachstate" (void* int) int)

;;int pthread_attr_setguardsize(pthread_attr_t*  ,size_t )
(def-function pthread-attr-setguardsize
             "c_pthread_attr_setguardsize" (void* int) int)

;;int pthread_attr_setinheritsched(pthread_attr_t*  ,int )
(def-function pthread-attr-setinheritsched
             "c_pthread_attr_setinheritsched" (void* int) int)

;;int pthread_attr_setschedparam(pthread_attr_t*  ,struct sched_param* )
(def-function pthread-attr-setschedparam
             "c_pthread_attr_setschedparam" (void* void*) int)

;;int pthread_attr_setschedpolicy(pthread_attr_t*  ,int )
(def-function pthread-attr-setschedpolicy
             "c_pthread_attr_setschedpolicy" (void* int) int)

;;int pthread_attr_setscope(pthread_attr_t*  ,int )
(def-function pthread-attr-setscope
             "c_pthread_attr_setscope" (void* int) int)

;;int pthread_attr_setstackaddr(pthread_attr_t*  ,void* )
(def-function pthread-attr-setstackaddr
             "c_pthread_attr_setstackaddr" (void* void*) int)

;;int pthread_attr_setstacksize(pthread_attr_t*  ,size_t )
(def-function pthread-attr-setstacksize
             "c_pthread_attr_setstacksize" (void* int) int)

;;int pthread_cancel(pthread_t )
(def-function pthread-cancel
             "c_pthread_cancel" (pthread_t) int)

;;void pthread_cleanup_push(void*  ,void* )
(def-function pthread-cleanup-push
             "c_pthread_cleanup_push" (void* void*) void)

;;void pthread_cleanup_pop(int )
(def-function pthread-cleanup-pop
             "c_pthread_cleanup_pop" (int) void)

;;int pthread_cond_broadcast(pthread_cond_t* )
(def-function pthread-cond-broadcast
             "c_pthread_cond_broadcast" (void*) int)

;;int pthread_cond_destroy(pthread_cond_t* )
(def-function pthread-cond-destroy
             "c_pthread_cond_destroy" (void*) int)

;;int pthread_cond_init(pthread_cond_t*  ,pthread_condattr_t* )
(def-function pthread-cond-init
             "c_pthread_cond_init" (void* void*) int)

;;int pthread_cond_signal(pthread_cond_t* )
(def-function pthread-cond-signal
             "c_pthread_cond_signal" (void*) int)

;;int pthread_cond_timedwait(pthread_cond_t*  ,pthread_mutex_t*  ,struct timespec* )
(def-function pthread-cond-timedwait
             "c_pthread_cond_timedwait" (void* void* void*) int)

;;int pthread_cond_wait(pthread_cond_t*  ,pthread_mutex_t* )
(def-function pthread-cond-wait
             "c_pthread_cond_wait" (void* void*) int)

;;int pthread_condattr_destroy(pthread_condattr_t* )
(def-function pthread-condattr-destroy
             "c_pthread_condattr_destroy" (void*) int)

;;int pthread_condattr_getpshared(pthread_condattr_t*  ,int* )
(def-function pthread-condattr-getpshared
             "c_pthread_condattr_getpshared" (void* void*) int)

;;int pthread_condattr_init(pthread_condattr_t* )
(def-function pthread-condattr-init
             "c_pthread_condattr_init" (void*) int)

;;int pthread_condattr_setpshared(pthread_condattr_t*  ,int )
(def-function pthread-condattr-setpshared
             "c_pthread_condattr_setpshared" (void* int) int)

;;int pthread_create(pthread_t*  ,pthread_attr_t*  ,void* )
(def-function pthread-create
             "c_pthread_create" (void* void* void* void*) int)

;;int pthread_detach(pthread_t )
(def-function pthread-detach
             "c_pthread_detach" (pthread_t) int)

;;int pthread_equal(pthread_t  ,pthread_t )
(def-function pthread-equal
             "c_pthread_equal" (pthread_t pthread_t) int)

;;void pthread_exit(void* )
(def-function pthread-exit
             "c_pthread_exit" (void*) void)

;;int pthread_getconcurrency(void )
(def-function pthread-getconcurrency
             "c_pthread_getconcurrency" (void) int)

;;int pthread_getschedparam(pthread_t  ,int*  ,struct sched_param* )
(def-function pthread-getschedparam
             "c_pthread_getschedparam" (pthread_t void* void*) int)

;;void* pthread_getspecific(pthread_key_t )
(def-function pthread-getspecific
             "c_pthread_getspecific" (pthread_key_t) void*)

;;int pthread_join(pthread_t  ,void )
(def-function pthread-join
             "c_pthread_join" (pthread_t void) int)

;;int pthread_key_create(pthread_key_t* )
(def-function pthread-key-create
             "c_pthread_key_create" (void*) int)

;;int pthread_key_delete(pthread_key_t )
(def-function pthread-key-delete
             "c_pthread_key_delete" (pthread_key_t) int)

;;int pthread_mutex_destroy(pthread_mutex_t* )
(def-function pthread-mutex-destroy
             "c_pthread_mutex_destroy" (void*) int)

;;int pthread_mutex_getprioceiling(pthread_mutex_t*  ,int* )
(def-function pthread-mutex-getprioceiling
             "c_pthread_mutex_getprioceiling" (void* void*) int)

;;int pthread_mutex_init(pthread_mutex_t*  ,pthread_mutexattr_t* )
(def-function pthread-mutex-init
             "c_pthread_mutex_init" (void* void*) int)

;;int pthread_mutex_lock(pthread_mutex_t* )
(def-function pthread-mutex-lock
             "c_pthread_mutex_lock" (void*) int)

;;int pthread_mutex_setprioceiling(pthread_mutex_t*  ,int  ,int* )
(def-function pthread-mutex-setprioceiling
             "c_pthread_mutex_setprioceiling" (void* int void*) int)

;;int pthread_mutex_trylock(pthread_mutex_t* )
(def-function pthread-mutex-trylock
             "c_pthread_mutex_trylock" (void*) int)

;;int pthread_mutex_unlock(pthread_mutex_t* )
(def-function pthread-mutex-unlock
             "c_pthread_mutex_unlock" (void*) int)

;;int pthread_mutexattr_destroy(pthread_mutexattr_t* )
(def-function pthread-mutexattr-destroy
             "c_pthread_mutexattr_destroy" (void*) int)

;;int pthread_mutexattr_getprioceiling(pthread_mutexattr_t*  ,int* )
(def-function pthread-mutexattr-getprioceiling
             "c_pthread_mutexattr_getprioceiling" (void* void*) int)

;;int pthread_mutexattr_getprotocol(pthread_mutexattr_t*  ,int* )
(def-function pthread-mutexattr-getprotocol
             "c_pthread_mutexattr_getprotocol" (void* void*) int)

;;int pthread_mutexattr_getpshared(pthread_mutexattr_t*  ,int* )
(def-function pthread-mutexattr-getpshared
             "c_pthread_mutexattr_getpshared" (void* void*) int)

;;int pthread_mutexattr_gettype(pthread_mutexattr_t*  ,int* )
(def-function pthread-mutexattr-gettype
             "c_pthread_mutexattr_gettype" (void* void*) int)

;;int pthread_mutexattr_init(pthread_mutexattr_t* )
(def-function pthread-mutexattr-init
             "c_pthread_mutexattr_init" (void*) int)

;;int pthread_mutexattr_setprioceiling(pthread_mutexattr_t*  ,int )
(def-function pthread-mutexattr-setprioceiling
             "c_pthread_mutexattr_setprioceiling" (void* int) int)

;;int pthread_mutexattr_setprotocol(pthread_mutexattr_t*  ,int )
(def-function pthread-mutexattr-setprotocol
             "c_pthread_mutexattr_setprotocol" (void* int) int)

;;int pthread_mutexattr_setpshared(pthread_mutexattr_t*  ,int )
(def-function pthread-mutexattr-setpshared
             "c_pthread_mutexattr_setpshared" (void* int) int)

;;int pthread_mutexattr_settype(pthread_mutexattr_t*  ,int )
(def-function pthread-mutexattr-settype
             "c_pthread_mutexattr_settype" (void* int) int)

;;int pthread_once(pthread_once_t* )
(def-function pthread-once
             "c_pthread_once" (void*) int)

;;int pthread_rwlock_destroy(pthread_rwlock_t* )
(def-function pthread-rwlock-destroy
             "c_pthread_rwlock_destroy" (void*) int)

;;int pthread_rwlock_init(pthread_rwlock_t*  ,pthread_rwlockattr_t* )
(def-function pthread-rwlock-init
             "c_pthread_rwlock_init" (void* void*) int)

;;int pthread_rwlock_rdlock(pthread_rwlock_t* )
(def-function pthread-rwlock-rdlock
             "c_pthread_rwlock_rdlock" (void*) int)

;;int pthread_rwlock_tryrdlock(pthread_rwlock_t* )
(def-function pthread-rwlock-tryrdlock
             "c_pthread_rwlock_tryrdlock" (void*) int)

;;int pthread_rwlock_trywrlock(pthread_rwlock_t* )
(def-function pthread-rwlock-trywrlock
             "c_pthread_rwlock_trywrlock" (void*) int)

;;int pthread_rwlock_unlock(pthread_rwlock_t* )
(def-function pthread-rwlock-unlock
             "c_pthread_rwlock_unlock" (void*) int)

;;int pthread_rwlock_wrlock(pthread_rwlock_t* )
(def-function pthread-rwlock-wrlock
             "c_pthread_rwlock_wrlock" (void*) int)

;;int pthread_rwlockattr_destroy(pthread_rwlockattr_t* )
(def-function pthread-rwlockattr-destroy
             "c_pthread_rwlockattr_destroy" (void*) int)

;;int pthread_rwlockattr_getpshared(pthread_rwlockattr_t*  ,int* )
(def-function pthread-rwlockattr-getpshared
             "c_pthread_rwlockattr_getpshared" (void* void*) int)

;;int pthread_rwlockattr_init(pthread_rwlockattr_t* )
(def-function pthread-rwlockattr-init
             "c_pthread_rwlockattr_init" (void*) int)

;;int pthread_rwlockattr_setpshared(pthread_rwlockattr_t*  ,int )
(def-function pthread-rwlockattr-setpshared
             "c_pthread_rwlockattr_setpshared" (void* int) int)

;;pthread_t pthread_self(void )
(def-function pthread-self
             "c_pthread_self" (void) pthread_t)

;;int pthread_setcancelstate(int  ,int* )
(def-function pthread-setcancelstate
             "c_pthread_setcancelstate" (int void*) int)

;;int pthread_setcanceltype(int  ,int* )
(def-function pthread-setcanceltype
             "c_pthread_setcanceltype" (int void*) int)

;;int pthread_setconcurrency(int )
(def-function pthread-setconcurrency
             "c_pthread_setconcurrency" (int) int)

;;int pthread_setschedparam(pthread_t  ,int  ,struct sched_param* )
(def-function pthread-setschedparam
             "c_pthread_setschedparam" (pthread_t int void*) int)

;;int pthread_setspecific(pthread_key_t  ,void* )
(def-function pthread-setspecific
             "c_pthread_setspecific" (pthread_key_t void*) int)

;;void pthread_testcancel(void )
(def-function pthread-testcancel
             "c_pthread_testcancel" (void) void)


)
