;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;作者:evilbinary on 11/19/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui video)
  (export
   video-new
   video-render
   video-destroy
   )

  (import (scheme) (utils libutil) (cffi cffi) (gles gles2) )
  (load-librarys "libvideo")

  (def-function video-new "video_new" (void* float float) void*)
  (def-function video-render "video_render" (void* float float float float) void)
  (def-function video-destroy "video_destroy" (void*) void)

 

  )
