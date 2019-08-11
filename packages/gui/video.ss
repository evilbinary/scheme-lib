;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Copyright 2016-2080 evilbinary.
;;作者:evilbinary on 12/24/16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (gui video)
  (export video-new video-render video-destroy video-get-fps
    video-set-pause video-get-duration video-set-soft-conver
    video-get-current-duration video-get-pause)
  (import (scheme) (utils libutil) (cffi cffi) (gles gles2))
  (load-librarys "libvideo")
  (def-function
    video-new
    "video_new"
    (void* float float)
    void*)
  (def-function
    video-render
    "video_render"
    (void* float float float float)
    void)
  (def-function video-destroy "video_destroy" (void*) void)
  (def-function video-get-fps "video_get_fps" (void*) int)
  (def-function
    video-set-pause
    "video_set_pause"
    (void* int)
    void)
  (def-function video-get-pause "video_get_pause" (void*) int)
  (def-function
    video-get-duration
    "video_get_duration"
    (void*)
    double)
  (def-function
    video-get-current-duration
    "video_get_current_duration"
    (void*)
    double)
  (def-function
    video-set-soft-conver
    "video_set_soft_conver"
    (void* int)
    void))

