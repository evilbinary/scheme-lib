;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Copyright 2016-2080 evilbinary.
;;作者:evilbinary on 11;19;16.
;;邮箱:rootdebug@163.com
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(library (glfw glfw)
  (export 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					; GLFW API tokens
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
   ;;! @name GLFW version macros
					;  @{ ;;
   ;;! @brief The major version number of the GLFW library.
					;
					;  This is incremented when the API is changed in non-compatible ways.
					;  @ingroup init
   ;;
   GLFW_VERSION_MAJOR          
;;! @brief The minor version number of the GLFW library.
 ;
 ;  This is incremented when features are added to the API but it remains
 ;  backward-compatible.
 ;  @ingroup init
 ;;
   GLFW_VERSION_MINOR          
;;! @brief The revision number of the GLFW library.
 ;
 ;  This is incremented when a bug fix release is made that does not contain any
 ;  API changes.
 ;  @ingroup init
 ;;
   GLFW_VERSION_REVISION        
;;! @} ;;

;;! @name Boolean values
 ;  @{ ;;
;;! @brief One.
 ;
 ;  One.  Seriously.  You don't _need_ to use this symbol in your code.  It's
 ;  just semantic sugar for the number 1.  You can use `1` or `true` or `_True`
 ;  or `GL_TRUE` or whatever you want.
 ;;
 GLFW_TRUE                    
;;! @brief Zero.
 ;
 ;  Zero.  Seriously.  You don't _need_ to use this symbol in your code.  It's
 ;  just just semantic sugar for the number 0.  You can use `0` or `false` or
 ;  `_False` or `GL_FALSE` or whatever you want.
 ;;
 GLFW_FALSE                   
;;! @} ;;

;;! @name Key and button actions
 ;  @{ ;;
;;! @brief The key or mouse button was released.
 ;
 ;  The key or mouse button was released.
 ;
 ;  @ingroup input
 ;;
 GLFW_RELEASE                 
 ;;! @brief The key or mouse button was pressed.
					;
					;  The key or mouse button was pressed.
					;
					;  @ingroup input
 ;;
 GLFW_PRESS                   
 ;;! @brief The key was held down until it repeated.
					;
					;  The key was held down until it repeated.
					;
					;  @ingroup input
 ;;
 GLFW_REPEAT                 
 ;;! @} ;;

 ;;! @defgroup keys Keyboard keys
					;
					;  See [key input](@ref input_key for how these are used.
					;
					;  These key codes are inspired by the _USB HID Usage Tables v1.12_ (p. 53-60,
					;  but re-arranged to map to 7-bit ASCII for printable keys (function keys are
					;  put in the 256+ range.
					;
					;  The naming of the key codes follow these rules:
					;   - The US keyboard layout is used
					;   - Names of printable alpha-numeric characters are used (e.g. "A", "R",
					;     "3", etc.
					;   - For non-alphanumeric characters, Unicode:ish names are used (e.g.
					;     "COMMA", "LEFT_SQUARE_BRACKET", etc.. Note that some names do not
					;     correspond to the Unicode standard (usually for brevity
					;   - Keys that lack a clear US mapping are named "WORLD_x"
					;   - For non-printable keys, custom names are used (e.g. "F4",
					;     "BACKSPACE", etc.
					;
					;  @ingroup input
					;  @{
 ;;

 ;; The unknown key ;;
 GLFW_KEY_UNKNOWN            

 ;; Printable keys ;;
 GLFW_KEY_SPACE              
 GLFW_KEY_APOSTROPHE           ;; ' ;;
 GLFW_KEY_COMMA                ;; , ;;
 GLFW_KEY_MINUS                ;; - ;;
 GLFW_KEY_PERIOD               ;; . ;;
 GLFW_KEY_SLASH                ;; ; ;;
 GLFW_KEY_0                  
 GLFW_KEY_1                  
 GLFW_KEY_2                  
 GLFW_KEY_3                  
 GLFW_KEY_4                  
 GLFW_KEY_5                  
 GLFW_KEY_6                  
 GLFW_KEY_7                  
 GLFW_KEY_8                  
 GLFW_KEY_9                  
 GLFW_KEY_SEMICOLON            ;; ; ;;
 GLFW_KEY_EQUAL                ;; = ;;
 GLFW_KEY_A                  
 GLFW_KEY_B                  
 GLFW_KEY_C                  
 GLFW_KEY_D                  
 GLFW_KEY_E                  
 GLFW_KEY_F                  
 GLFW_KEY_G                  
 GLFW_KEY_H                  
 GLFW_KEY_I                  
 GLFW_KEY_J                  
 GLFW_KEY_K                  
 GLFW_KEY_L                  
 GLFW_KEY_M                  
 GLFW_KEY_N                  
 GLFW_KEY_O                  
 GLFW_KEY_P                  
 GLFW_KEY_Q                  
 GLFW_KEY_R                  
 GLFW_KEY_S                  
 GLFW_KEY_T                  
 GLFW_KEY_U                  
 GLFW_KEY_V                  
 GLFW_KEY_W                  
 GLFW_KEY_X                  
 GLFW_KEY_Y                  
 GLFW_KEY_Z                  
 GLFW_KEY_LEFT_BRACKET        ;; [ ;;
 GLFW_KEY_BACKSLASH           ;; \ ;;
 GLFW_KEY_RIGHT_BRACKET       ;; ] ;;
 GLFW_KEY_GRAVE_ACCENT        ;; ` ;;
 GLFW_KEY_WORLD_1             ;; non-US #1 ;;
 GLFW_KEY_WORLD_2             ;; non-US #2 ;;

 ;; Function keys ;;
 GLFW_KEY_ESCAPE             
 GLFW_KEY_ENTER              
 GLFW_KEY_TAB                
 GLFW_KEY_BACKSPACE          
 GLFW_KEY_INSERT             
 GLFW_KEY_DELETE             
 GLFW_KEY_RIGHT              
 GLFW_KEY_LEFT               
 GLFW_KEY_DOWN               
 GLFW_KEY_UP                 
 GLFW_KEY_PAGE_UP            
 GLFW_KEY_PAGE_DOWN          
 GLFW_KEY_HOME               
 GLFW_KEY_END                
 GLFW_KEY_CAPS_LOCK          
 GLFW_KEY_SCROLL_LOCK        
 GLFW_KEY_NUM_LOCK           
 GLFW_KEY_PRINT_SCREEN       
 GLFW_KEY_PAUSE              
 GLFW_KEY_F1                 
 GLFW_KEY_F2                 
 GLFW_KEY_F3                 
 GLFW_KEY_F4                 
 GLFW_KEY_F5                 
 GLFW_KEY_F6                 
 GLFW_KEY_F7                 
 GLFW_KEY_F8                 
 GLFW_KEY_F9                 
 GLFW_KEY_F10                
 GLFW_KEY_F11                
 GLFW_KEY_F12                
 GLFW_KEY_F13                
 GLFW_KEY_F14                
 GLFW_KEY_F15                
 GLFW_KEY_F16                
 GLFW_KEY_F17                
 GLFW_KEY_F18                
 GLFW_KEY_F19                
 GLFW_KEY_F20                
 GLFW_KEY_F21                
 GLFW_KEY_F22                
 GLFW_KEY_F23                
 GLFW_KEY_F24                
 GLFW_KEY_F25                
 GLFW_KEY_KP_0               
 GLFW_KEY_KP_1               
 GLFW_KEY_KP_2               
 GLFW_KEY_KP_3               
 GLFW_KEY_KP_4               
 GLFW_KEY_KP_5               
 GLFW_KEY_KP_6               
 GLFW_KEY_KP_7               
 GLFW_KEY_KP_8               
 GLFW_KEY_KP_9               
 GLFW_KEY_KP_DECIMAL         
 GLFW_KEY_KP_DIVIDE          
 GLFW_KEY_KP_MULTIPLY        
 GLFW_KEY_KP_SUBTRACT        
 GLFW_KEY_KP_ADD             
 GLFW_KEY_KP_ENTER           
 GLFW_KEY_KP_EQUAL           
 GLFW_KEY_LEFT_SHIFT         
 GLFW_KEY_LEFT_CONTROL       
 GLFW_KEY_LEFT_ALT           
 GLFW_KEY_LEFT_SUPER         
 GLFW_KEY_RIGHT_SHIFT        
 GLFW_KEY_RIGHT_CONTROL      
 GLFW_KEY_RIGHT_ALT          
 GLFW_KEY_RIGHT_SUPER        
 GLFW_KEY_MENU               

 GLFW_KEY_LAST              

 ;;! @} ;;

 ;;! @defgroup mods Modifier key flags
					;
					;  See [key input](@ref input_key for how these are used.
					;
					;  @ingroup input
					;  @{ ;;

 ;;! @brief If this bit is set one or more Shift keys were held down.
 ;;
 GLFW_MOD_SHIFT          
 ;;! @brief If this bit ise or more Control keys were held down.
 ;;
 GLFW_MOD_CONTROL        
 ;;! @brief If this bit ise or more Alt keys were held down.
 ;;
 GLFW_MOD_ALT            
 ;;! @brief If this bit ise or more Super keys were held down.
 ;;
 GLFW_MOD_SUPER          

 ;;! @} ;;

 ;;! @defgroup buttons Mouse buttons
					;
					;  See [mouse button input](@ref input_mouse_button for how these are used.
					;
					;  @ingroup input
					;  @{ ;;
 GLFW_MOUSE_BUTTON_1         
 GLFW_MOUSE_BUTTON_2         
 GLFW_MOUSE_BUTTON_3         
 GLFW_MOUSE_BUTTON_4         
 GLFW_MOUSE_BUTTON_5         
 GLFW_MOUSE_BUTTON_6         
 GLFW_MOUSE_BUTTON_7         
 GLFW_MOUSE_BUTTON_8         
 GLFW_MOUSE_BUTTON_LAST      
 GLFW_MOUSE_BUTTON_LEFT      
 GLFW_MOUSE_BUTTON_RIGHT     
 GLFW_MOUSE_BUTTON_MIDDLE    
 ;;! @} ;;

 ;;! @defgroup joysticks Joysticks
					;
					;  See [joystick input](@ref joystick for how these are used.
					;
					;  @ingroup input
					;  @{ ;;
 GLFW_JOYSTICK_1             
 GLFW_JOYSTICK_2             
 GLFW_JOYSTICK_3             
 GLFW_JOYSTICK_4             
 GLFW_JOYSTICK_5             
 GLFW_JOYSTICK_6             
 GLFW_JOYSTICK_7             
 GLFW_JOYSTICK_8             
 GLFW_JOYSTICK_9             
 GLFW_JOYSTICK_10            
 GLFW_JOYSTICK_11            
 GLFW_JOYSTICK_12            
 GLFW_JOYSTICK_13            
 GLFW_JOYSTICK_14            
 GLFW_JOYSTICK_15            
 GLFW_JOYSTICK_16            
 GLFW_JOYSTICK_LAST          
 ;;! @} ;;

 ;;! @defgroup errors Error codes
					;
					;  See [error handling](@ref error_handling for how these are used.
					;
					;  @ingroup init
					;  @{ ;;
 ;;! @brief GLFW has not been initialized.
					;
					;  This occurs if a GLFW function was called that must not be called unless the
					;  library is [initialized](@ref intro_init.
					;
					;  @analysis Application programmer error.  Initialize GLFW before calling any
					;  function that requires initialization.
 ;;
 GLFW_NOT_INITIALIZED      
 ;;! @brief No context is current for this thread.
					;
					;  This occurs if a GLFW function was called that needs and operates on the
					;  current OpenGL or OpenGL ES context but no context is current on the calling
					;  thread.  One such function is @ref glfwSwapInterval.
					;
					;  @analysis Application programmer error.  Ensure a context is current before
					;  calling functions that require a current context.
 ;;
 GLFW_NO_CURRENT_CONTEXT     
 ;;! @brief One of the arguments to the function was an invalid enum value.
					;
					;  One of the arguments to the function was an invalid enum value, for example
					;  requesting [GLFW_RED_BITS](@ref window_hints_fb with @ref
					;  glfwGetWindowAttrib.
					;
					;  @analysis Application programmer error.  Fix the offending call.
 ;;
 GLFW_INVALID_ENUM           
 ;;! @brief One of the arguments to the function was an invalid value.
					;
					;  One of the arguments to the function was an invalid value, for example
					;  requesting a non-existent OpenGL or OpenGL ES version like 2.7.
					;
					;  Requesting a valid but unavailable OpenGL or OpenGL ES version will instead
					;  result in a @ref GLFW_VERSION_UNAVAILABLE error.
					;
					;  @analysis Application programmer error.  Fix the offending call.
 ;;
 GLFW_INVALID_VALUE         
 ;;! @brief A memory allocation failed.
					;
					;  A memory allocation failed.
					;
					;  @analysis A bug in GLFW or the underlying operating system.  Report the bug
					;  to our [issue tracker](https:;;github.com;glfw;glfw;issues.
 ;;
 GLFW_OUT_OF_MEMORY          
 ;;! @brief GLFW could not find support for the requested API on the system.
					;
					;  GLFW could not find support for the requested API on the system.
					;
					;  @analysis The installed graphics driver does not support the requested
					;  API, or does not support it via the chosen context creation backend.
					;  Below are a few examples.
					;
					;  @par
					;  Some pre-installed Windows graphics drivers do not support OpenGL.  AMD only
					;  supports OpenGL ES via EGL, while Nvidia and Intel only support it via
					;  a WGL or GLX extension.  OS X does not provide OpenGL ES at all.  The Mesa
					;  EGL, OpenGL and OpenGL ES libraries do not interface with the Nvidia binary
					;  driver.  Older graphics drivers do not support Vulkan.
 ;;
 GLFW_API_UNAVAILABLE        
 ;;! @brief The requested OpenGL or OpenGL ES version is not available.
					;
					;  The requested OpenGL or OpenGL ES version (including any requested context
					;  or framebuffer hints is not available on this machine.
					;
					;  @analysis The machine does not support your requirements.  If your
					;  application is sufficiently flexible, downgrade your requirements and try
					;  again.  Otherwise, inform the user that their machine does not match your
					;  requirements.
					;
					;  @par
					;  Future invalid OpenGL and OpenGL ES versions, for example OpenGL 4.8 if 5.0
					;  comes out before the 4.x series gets that far, also fail with this error and
					;  not @ref GLFW_INVALID_VALUE, because GLFW cannot know what future versions
					;  will exist.
 ;;
 GLFW_VERSION_UNAVAILABLE    
 ;;! @brief A platform-specific error occurred that does not match any of the
					;  more specific categories.
					;
					;  A platform-specific error occurred that does not match any of the more
					;  specific categories.
					;
					;  @analysis A bug or configuration error in GLFW, the underlying operating
					;  system or its drivers, or a lack of required resources.  Report the issue to
					;  our [issue tracker](https:;;github.com;glfw;glfw;issues.
 ;;
 GLFW_PLATFORM_ERROR        
 ;;! @brief The requested format is not supported or available.
					;
					;  If emitted during window creation, the requested pixel format is not
					;  supported.
					;
					;  If emitted when querying the clipboard, the contents of the clipboard could
					;  not be converted to the requested format.
					;
					;  @analysis If emitted during window creation, one or more
					;  [hard constraints](@ref window_hints_hard did not match any of the
					;  available pixel formats.  If your application is sufficiently flexible,
					;  downgrade your requirements and try again.  Otherwise, inform the user that
					;  their machine does not match your requirements.
					;
					;  @par
					;  If emitted when querying the clipboard, ignore the error or report it to
					;  the user, as appropriate.
 ;;
 GLFW_FORMAT_UNAVAILABLE    
 ;;! @brief The specified window does not have an OpenGL or OpenGL ES context.
					;
					;  A window that does not have an OpenGL or OpenGL ES context was passed to
					;  a function that requires it to have one.
					;
					;  @analysis Application programmer error.  Fix the offending call.
 ;;
 GLFW_NO_WINDOW_CONTEXT     
 ;;! @} ;;

 GLFW_FOCUSED               
 GLFW_ICONIFIED             
 GLFW_RESIZABLE             
 GLFW_VISIBLE               
 GLFW_DECORATED             
 GLFW_AUTO_ICONIFY          
 GLFW_FLOATING              
 GLFW_MAXIMIZED             

 GLFW_RED_BITS              
 GLFW_GREEN_BITS            
 GLFW_BLUE_BITS             
 GLFW_ALPHA_BITS            
 GLFW_DEPTH_BITS            
 GLFW_STENCIL_BITS          
 GLFW_ACCUM_RED_BITS        
 GLFW_ACCUM_GREEN_BITS      
 GLFW_ACCUM_BLUE_BITS       
 GLFW_ACCUM_ALPHA_BITS      
 GLFW_AUX_BUFFERS           
 GLFW_STEREO                
 GLFW_SAMPLES               
 GLFW_SRGB_CAPABLE          
 GLFW_REFRESH_RATE          
 GLFW_DOUBLEBUFFER          

 GLFW_CLIENT_API            
 GLFW_CONTEXT_VERSION_MAJOR 
 GLFW_CONTEXT_VERSION_MINOR 
 GLFW_CONTEXT_REVISION      
 GLFW_CONTEXT_ROBUSTNESS    
 GLFW_OPENGL_FORWARD_COMPAT 
 GLFW_OPENGL_DEBUG_CONTEXT  
 GLFW_OPENGL_PROFILE        
 GLFW_CONTEXT_RELEASE_BEHAVIOR  
 GLFW_CONTEXT_NO_ERROR       
 GLFW_CONTEXT_CREATION_API   

 GLFW_NO_API                
 GLFW_OPENGL_API            
 GLFW_OPENGL_ES_API         

 GLFW_NO_ROBUSTNESS         
 GLFW_NO_RESET_NOTIFICATION 
 GLFW_LOSE_CONTEXT_ON_RESET 

 GLFW_OPENGL_ANY_PROFILE    
 GLFW_OPENGL_CORE_PROFILE   
 GLFW_OPENGL_COMPAT_PROFILE 

 GLFW_CURSOR                
 GLFW_STICKY_KEYS           
 GLFW_STICKY_MOUSE_BUTTONS  

 GLFW_CURSOR_NORMAL         
 GLFW_CURSOR_HIDDEN         
 GLFW_CURSOR_DISABLED       

 GLFW_ANY_RELEASE_BEHAVIOR            
 GLFW_RELEASE_BEHAVIOR_FLUSH  
 GLFW_RELEASE_BEHAVIOR_NONE  

 GLFW_NATIVE_CONTEXT_API    
 GLFW_EGL_CONTEXT_API       

 ;;! @defgroup shapes Standard cursor shapes
					;
					;  See [standard cursor creation](@ref cursor_standard for how these are used.
					;
					;  @ingroup input
					;  @{ ;;

 ;;! @brief The regular arrow cursor shape.
					;
					;  The regular arrow cursor.
 ;;
 GLFW_ARROW_CURSOR           
 ;;! @brief The text input I-beam cursor shape.
					;
					;  The text input I-beam cursor shape.
 ;;
 GLFW_IBEAM_CURSOR          
 ;;! @brief The crosshair shape.
					;
					;  The crosshair shape.
 ;;
 GLFW_CROSSHAIR_CURSOR      
 ;;! @brief The hand shape.
					;
					;  The hand shape.
 ;;
 GLFW_HAND_CURSOR           
 ;;! @brief The horizontal resize arrow shape.
					;
					;  The horizontal resize arrow shape.
 ;;
 GLFW_HRESIZE_CURSOR        
 ;;! @brief The vertical resize arrow shape.
					;
					;  The vertical resize arrow shape.
 ;;
 GLFW_VRESIZE_CURSOR         
 ;;! @} ;;

 GLFW_CONNECTED             
 GLFW_DISCONNECTED          

 GLFW_DONT_CARE    


 glfw-init 
 glfw-window-hint

 
 glfw-window-hint 
 glfw-create-window 
 glfw-terminate 
 glfw-terminate 
 
 glfw-make-context-current
 
 glfw-swap-interval
 
					;gladLoadGLLoader
 glfw-window-should-close
 
 glfw-get-framebuffer-size
 
 glfw-swap-buffers
 
 glfw-poll-events
 glfw-wait-events
 
 glfw-destroy-window
 glfw-create-standard-cursor
 glfw-set-cursor
 
 get-glfw-get-proc-address
 glfw-make-cursor-pos-callback
 glfw-set-cursor-pos-callback
 glfw-set-key-callback
 glfw-set-window-size-callback
 glfw-set-mouse-button-callback
 glfw-make-mouse-button-callback
 glfw-set-scroll-callback
 glfw-make-scroll-callback
 glfw-make-char-callback
 glfw-set-char-callback 
 glfw-get-clipboard-string
 glfw-set-clipboard-string
 
 glad-load-gl
 glad-load-gl-loader
 glad-load-gles2-loader
 glad-load-gles1-loader
 

 )	

  (import (scheme) (utils libutil) )
  ;;define
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					; GLFW API tokens
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;;! @name GLFW version macros
					;  @{ ;;
  ;;! @brief The major version number of the GLFW library.
					;
					;  This is incremented when the API is changed in non-compatible ways.
					;  @ingroup init
  ;;
  (define GLFW_VERSION_MAJOR          3)
  ;;! @brief The minor version number of the GLFW library.
					;
					;  This is incremented when features are added to the API but it remains
					;  backward-compatible.
					;  @ingroup init
  ;;
  (define GLFW_VERSION_MINOR          2)
  ;;! @brief The revision number of the GLFW library.
					;
					;  This is incremented when a bug fix release is made that does not contain any
					;  API changes.
					;  @ingroup init
  ;;
  (define GLFW_VERSION_REVISION       1)
  ;;! @} ;;

  ;;! @name Boolean values
					;  @{ ;;
  ;;! @brief One.
					;
					;  One.  Seriously.  You don't _need_ to use this symbol in your code.  It's
					;  just semantic sugar for the number 1.  You can use `1` or `true` or `_True`
					;  or `GL_TRUE` or whatever you want.
  ;;
  (define GLFW_TRUE                   1)
  ;;! @brief Zero.
					;
					;  Zero.  Seriously.  You don't _need_ to use this symbol in your code.  It's
					;  just just semantic sugar for the number 0.  You can use `0` or `false` or
					;  `_False` or `GL_FALSE` or whatever you want.
  ;;
  (define GLFW_FALSE                  0)
  ;;! @} ;;

  ;;! @name Key and button actions
					;  @{ ;;
  ;;! @brief The key or mouse button was released.
					;
					;  The key or mouse button was released.
					;
					;  @ingroup input
  ;;
  (define GLFW_RELEASE                0)
  ;;! @brief The key or mouse button was pressed.
					;
					;  The key or mouse button was pressed.
					;
					;  @ingroup input
  ;;
  (define GLFW_PRESS                  1)
  ;;! @brief The key was held down until it repeated.
					;
					;  The key was held down until it repeated.
					;
					;  @ingroup input
  ;;
  (define GLFW_REPEAT                 2)
  ;;! @} ;;

  ;;! @defgroup keys Keyboard keys
					;
					;  See [key input](@ref input_key) for how these are used.
					;
					;  These key codes are inspired by the _USB HID Usage Tables v1.12_ (p. 53-60),
					;  but re-arranged to map to 7-bit ASCII for printable keys (function keys are
					;  put in the 256+ range).
					;
					;  The naming of the key codes follow these rules:
					;   - The US keyboard layout is used
					;   - Names of printable alpha-numeric characters are used (e.g. "A", "R",
					;     "3", etc.)
					;   - For non-alphanumeric characters, Unicode:ish names are used (e.g.
					;     "COMMA", "LEFT_SQUARE_BRACKET", etc.). Note that some names do not
					;     correspond to the Unicode standard (usually for brevity)
					;   - Keys that lack a clear US mapping are named "WORLD_x"
					;   - For non-printable keys, custom names are used (e.g. "F4",
					;     "BACKSPACE", etc.)
					;
					;  @ingroup input
					;  @{
  ;;

  ;; The unknown key ;;
  (define GLFW_KEY_UNKNOWN            -1)

  ;; Printable keys ;;
  (define GLFW_KEY_SPACE              32)
  (define GLFW_KEY_APOSTROPHE         39)  ;; ' ;;
  (define GLFW_KEY_COMMA              44)  ;; , ;;
  (define GLFW_KEY_MINUS              45)  ;; - ;;
  (define GLFW_KEY_PERIOD             46)  ;; . ;;
  (define GLFW_KEY_SLASH              47)  ;; ; ;;
  (define GLFW_KEY_0                  48)
  (define GLFW_KEY_1                  49)
  (define GLFW_KEY_2                  50)
  (define GLFW_KEY_3                  51)
  (define GLFW_KEY_4                  52)
  (define GLFW_KEY_5                  53)
  (define GLFW_KEY_6                  54)
  (define GLFW_KEY_7                  55)
  (define GLFW_KEY_8                  56)
  (define GLFW_KEY_9                  57)
  (define GLFW_KEY_SEMICOLON          59)  ;; ; ;;
  (define GLFW_KEY_EQUAL              61)  ;; = ;;
  (define GLFW_KEY_A                  65)
  (define GLFW_KEY_B                  66)
  (define GLFW_KEY_C                  67)
  (define GLFW_KEY_D                  68)
  (define GLFW_KEY_E                  69)
  (define GLFW_KEY_F                  70)
  (define GLFW_KEY_G                  71)
  (define GLFW_KEY_H                  72)
  (define GLFW_KEY_I                  73)
  (define GLFW_KEY_J                  74)
  (define GLFW_KEY_K                  75)
  (define GLFW_KEY_L                  76)
  (define GLFW_KEY_M                  77)
  (define GLFW_KEY_N                  78)
  (define GLFW_KEY_O                  79)
  (define GLFW_KEY_P                  80)
  (define GLFW_KEY_Q                  81)
  (define GLFW_KEY_R                  82)
  (define GLFW_KEY_S                  83)
  (define GLFW_KEY_T                  84)
  (define GLFW_KEY_U                  85)
  (define GLFW_KEY_V                  86)
  (define GLFW_KEY_W                  87)
  (define GLFW_KEY_X                  88)
  (define GLFW_KEY_Y                  89)
  (define GLFW_KEY_Z                  90)
  (define GLFW_KEY_LEFT_BRACKET       91)  ;; [ ;;
  (define GLFW_KEY_BACKSLASH          92)  ;; \ ;;
  (define GLFW_KEY_RIGHT_BRACKET      93)  ;; ] ;;
  (define GLFW_KEY_GRAVE_ACCENT       96)  ;; ` ;;
  (define GLFW_KEY_WORLD_1            161) ;; non-US #1 ;;
  (define GLFW_KEY_WORLD_2            162) ;; non-US #2 ;;

  ;; Function keys ;;
  (define GLFW_KEY_ESCAPE             256)
  (define GLFW_KEY_ENTER              257)
  (define GLFW_KEY_TAB                258)
  (define GLFW_KEY_BACKSPACE          259)
  (define GLFW_KEY_INSERT             260)
  (define GLFW_KEY_DELETE             261)
  (define GLFW_KEY_RIGHT              262)
  (define GLFW_KEY_LEFT               263)
  (define GLFW_KEY_DOWN               264)
  (define GLFW_KEY_UP                 265)
  (define GLFW_KEY_PAGE_UP            266)
  (define GLFW_KEY_PAGE_DOWN          267)
  (define GLFW_KEY_HOME               268)
  (define GLFW_KEY_END                269)
  (define GLFW_KEY_CAPS_LOCK          280)
  (define GLFW_KEY_SCROLL_LOCK        281)
  (define GLFW_KEY_NUM_LOCK           282)
  (define GLFW_KEY_PRINT_SCREEN       283)
  (define GLFW_KEY_PAUSE              284)
  (define GLFW_KEY_F1                 290)
  (define GLFW_KEY_F2                 291)
  (define GLFW_KEY_F3                 292)
  (define GLFW_KEY_F4                 293)
  (define GLFW_KEY_F5                 294)
  (define GLFW_KEY_F6                 295)
  (define GLFW_KEY_F7                 296)
  (define GLFW_KEY_F8                 297)
  (define GLFW_KEY_F9                 298)
  (define GLFW_KEY_F10                299)
  (define GLFW_KEY_F11                300)
  (define GLFW_KEY_F12                301)
  (define GLFW_KEY_F13                302)
  (define GLFW_KEY_F14                303)
  (define GLFW_KEY_F15                304)
  (define GLFW_KEY_F16                305)
  (define GLFW_KEY_F17                306)
  (define GLFW_KEY_F18                307)
  (define GLFW_KEY_F19                308)
  (define GLFW_KEY_F20                309)
  (define GLFW_KEY_F21                310)
  (define GLFW_KEY_F22                311)
  (define GLFW_KEY_F23                312)
  (define GLFW_KEY_F24                313)
  (define GLFW_KEY_F25                314)
  (define GLFW_KEY_KP_0               320)
  (define GLFW_KEY_KP_1               321)
  (define GLFW_KEY_KP_2               322)
  (define GLFW_KEY_KP_3               323)
  (define GLFW_KEY_KP_4               324)
  (define GLFW_KEY_KP_5               325)
  (define GLFW_KEY_KP_6               326)
  (define GLFW_KEY_KP_7               327)
  (define GLFW_KEY_KP_8               328)
  (define GLFW_KEY_KP_9               329)
  (define GLFW_KEY_KP_DECIMAL         330)
  (define GLFW_KEY_KP_DIVIDE          331)
  (define GLFW_KEY_KP_MULTIPLY        332)
  (define GLFW_KEY_KP_SUBTRACT        333)
  (define GLFW_KEY_KP_ADD             334)
  (define GLFW_KEY_KP_ENTER           335)
  (define GLFW_KEY_KP_EQUAL           336)
  (define GLFW_KEY_LEFT_SHIFT         340)
  (define GLFW_KEY_LEFT_CONTROL       341)
  (define GLFW_KEY_LEFT_ALT           342)
  (define GLFW_KEY_LEFT_SUPER         343)
  (define GLFW_KEY_RIGHT_SHIFT        344)
  (define GLFW_KEY_RIGHT_CONTROL      345)
  (define GLFW_KEY_RIGHT_ALT          346)
  (define GLFW_KEY_RIGHT_SUPER        347)
  (define GLFW_KEY_MENU               348)

  (define GLFW_KEY_LAST               GLFW_KEY_MENU)

  ;;! @} ;;

  ;;! @defgroup mods Modifier key flags
					;
					;  See [key input](@ref input_key) for how these are used.
					;
					;  @ingroup input
					;  @{ ;;

  ;;! @brief If this bit is set one or more Shift keys were held down.
  ;;
  (define GLFW_MOD_SHIFT          #x0001)
  ;;! @brief If this bit is set one or more Control keys were held down.
  ;;
  (define GLFW_MOD_CONTROL        #x0002)
  ;;! @brief If this bit is set one or more Alt keys were held down.
  ;;
  (define GLFW_MOD_ALT            #x0004)
  ;;! @brief If this bit is set one or more Super keys were held down.
  ;;
  (define GLFW_MOD_SUPER          #x0008)

  ;;! @} ;;

  ;;! @defgroup buttons Mouse buttons
					;
					;  See [mouse button input](@ref input_mouse_button) for how these are used.
					;
					;  @ingroup input
					;  @{ ;;
  (define GLFW_MOUSE_BUTTON_1         0)
  (define GLFW_MOUSE_BUTTON_2         1)
  (define GLFW_MOUSE_BUTTON_3         2)
  (define GLFW_MOUSE_BUTTON_4         3)
  (define GLFW_MOUSE_BUTTON_5         4)
  (define GLFW_MOUSE_BUTTON_6         5)
  (define GLFW_MOUSE_BUTTON_7         6)
  (define GLFW_MOUSE_BUTTON_8         7)
  (define GLFW_MOUSE_BUTTON_LAST      GLFW_MOUSE_BUTTON_8)
  (define GLFW_MOUSE_BUTTON_LEFT      GLFW_MOUSE_BUTTON_1)
  (define GLFW_MOUSE_BUTTON_RIGHT     GLFW_MOUSE_BUTTON_2)
  (define GLFW_MOUSE_BUTTON_MIDDLE    GLFW_MOUSE_BUTTON_3)
  ;;! @} ;;

  ;;! @defgroup joysticks Joysticks
					;
					;  See [joystick input](@ref joystick) for how these are used.
					;
					;  @ingroup input
					;  @{ ;;
  (define GLFW_JOYSTICK_1             0)
  (define GLFW_JOYSTICK_2             1)
  (define GLFW_JOYSTICK_3             2)
  (define GLFW_JOYSTICK_4             3)
  (define GLFW_JOYSTICK_5             4)
  (define GLFW_JOYSTICK_6             5)
  (define GLFW_JOYSTICK_7             6)
  (define GLFW_JOYSTICK_8             7)
  (define GLFW_JOYSTICK_9             8)
  (define GLFW_JOYSTICK_10            9)
  (define GLFW_JOYSTICK_11            10)
  (define GLFW_JOYSTICK_12            11)
  (define GLFW_JOYSTICK_13            12)
  (define GLFW_JOYSTICK_14            13)
  (define GLFW_JOYSTICK_15            14)
  (define GLFW_JOYSTICK_16            15)
  (define GLFW_JOYSTICK_LAST          GLFW_JOYSTICK_16)
  ;;! @} ;;

  ;;! @defgroup errors Error codes
					;
					;  See [error handling](@ref error_handling) for how these are used.
					;
					;  @ingroup init
					;  @{ ;;
  ;;! @brief GLFW has not been initialized.
					;
					;  This occurs if a GLFW function was called that must not be called unless the
					;  library is [initialized](@ref intro_init).
					;
					;  @analysis Application programmer error.  Initialize GLFW before calling any
					;  function that requires initialization.
  ;;
  (define GLFW_NOT_INITIALIZED      #x00010001)
  ;;! @brief No context is current for this thread.
					;
					;  This occurs if a GLFW function was called that needs and operates on the
					;  current OpenGL or OpenGL ES context but no context is current on the calling
					;  thread.  One such function is @ref glfwSwapInterval.
					;
					;  @analysis Application programmer error.  Ensure a context is current before
					;  calling functions that require a current context.
  ;;
  (define GLFW_NO_CURRENT_CONTEXT    #x00010002)
  ;;! @brief One of the arguments to the function was an invalid enum value.
					;
					;  One of the arguments to the function was an invalid enum value, for example
					;  requesting [GLFW_RED_BITS](@ref window_hints_fb) with @ref
					;  glfwGetWindowAttrib.
					;
					;  @analysis Application programmer error.  Fix the offending call.
  ;;
  (define GLFW_INVALID_ENUM          #x00010003)
  ;;! @brief One of the arguments to the function was an invalid value.
					;
					;  One of the arguments to the function was an invalid value, for example
					;  requesting a non-existent OpenGL or OpenGL ES version like 2.7.
					;
					;  Requesting a valid but unavailable OpenGL or OpenGL ES version will instead
					;  result in a @ref GLFW_VERSION_UNAVAILABLE error.
					;
					;  @analysis Application programmer error.  Fix the offending call.
  ;;
  (define GLFW_INVALID_VALUE         #x00010004)
  ;;! @brief A memory allocation failed.
					;
					;  A memory allocation failed.
					;
					;  @analysis A bug in GLFW or the underlying operating system.  Report the bug
					;  to our [issue tracker](https:;;github.com;glfw;glfw;issues).
  ;;
  (define GLFW_OUT_OF_MEMORY         #x00010005)
  ;;! @brief GLFW could not find support for the requested API on the system.
					;
					;  GLFW could not find support for the requested API on the system.
					;
					;  @analysis The installed graphics driver does not support the requested
					;  API, or does not support it via the chosen context creation backend.
					;  Below are a few examples.
					;
					;  @par
					;  Some pre-installed Windows graphics drivers do not support OpenGL.  AMD only
					;  supports OpenGL ES via EGL, while Nvidia and Intel only support it via
					;  a WGL or GLX extension.  OS X does not provide OpenGL ES at all.  The Mesa
					;  EGL, OpenGL and OpenGL ES libraries do not interface with the Nvidia binary
					;  driver.  Older graphics drivers do not support Vulkan.
  ;;
  (define GLFW_API_UNAVAILABLE       #x00010006)
  ;;! @brief The requested OpenGL or OpenGL ES version is not available.
					;
					;  The requested OpenGL or OpenGL ES version (including any requested context
					;  or framebuffer hints) is not available on this machine.
					;
					;  @analysis The machine does not support your requirements.  If your
					;  application is sufficiently flexible, downgrade your requirements and try
					;  again.  Otherwise, inform the user that their machine does not match your
					;  requirements.
					;
					;  @par
					;  Future invalid OpenGL and OpenGL ES versions, for example OpenGL 4.8 if 5.0
					;  comes out before the 4.x series gets that far, also fail with this error and
					;  not @ref GLFW_INVALID_VALUE, because GLFW cannot know what future versions
					;  will exist.
  ;;
  (define GLFW_VERSION_UNAVAILABLE   #x00010007)
  ;;! @brief A platform-specific error occurred that does not match any of the
					;  more specific categories.
					;
					;  A platform-specific error occurred that does not match any of the more
					;  specific categories.
					;
					;  @analysis A bug or configuration error in GLFW, the underlying operating
					;  system or its drivers, or a lack of required resources.  Report the issue to
					;  our [issue tracker](https:;;github.com;glfw;glfw;issues).
  ;;
  (define GLFW_PLATFORM_ERROR        #x00010008)
  ;;! @brief The requested format is not supported or available.
					;
					;  If emitted during window creation, the requested pixel format is not
					;  supported.
					;
					;  If emitted when querying the clipboard, the contents of the clipboard could
					;  not be converted to the requested format.
					;
					;  @analysis If emitted during window creation, one or more
					;  [hard constraints](@ref window_hints_hard) did not match any of the
					;  available pixel formats.  If your application is sufficiently flexible,
					;  downgrade your requirements and try again.  Otherwise, inform the user that
					;  their machine does not match your requirements.
					;
					;  @par
					;  If emitted when querying the clipboard, ignore the error or report it to
					;  the user, as appropriate.
  ;;
  (define GLFW_FORMAT_UNAVAILABLE    #x00010009)
  ;;! @brief The specified window does not have an OpenGL or OpenGL ES context.
					;
					;  A window that does not have an OpenGL or OpenGL ES context was passed to
					;  a function that requires it to have one.
					;
					;  @analysis Application programmer error.  Fix the offending call.
  ;;
  (define GLFW_NO_WINDOW_CONTEXT     #x0001000A)
  ;;! @} ;;

  (define GLFW_FOCUSED               #x00020001)
  (define GLFW_ICONIFIED             #x00020002)
  (define GLFW_RESIZABLE             #x00020003)
  (define GLFW_VISIBLE               #x00020004)
  (define GLFW_DECORATED             #x00020005)
  (define GLFW_AUTO_ICONIFY          #x00020006)
  (define GLFW_FLOATING              #x00020007)
  (define GLFW_MAXIMIZED             #x00020008)

  (define GLFW_RED_BITS              #x00021001)
  (define GLFW_GREEN_BITS            #x00021002)
  (define GLFW_BLUE_BITS             #x00021003)
  (define GLFW_ALPHA_BITS            #x00021004)
  (define GLFW_DEPTH_BITS            #x00021005)
  (define GLFW_STENCIL_BITS          #x00021006)
  (define GLFW_ACCUM_RED_BITS        #x00021007)
  (define GLFW_ACCUM_GREEN_BITS      #x00021008)
  (define GLFW_ACCUM_BLUE_BITS       #x00021009)
  (define GLFW_ACCUM_ALPHA_BITS      #x0002100A)
  (define GLFW_AUX_BUFFERS           #x0002100B)
  (define GLFW_STEREO                #x0002100C)
  (define GLFW_SAMPLES               #x0002100D)
  (define GLFW_SRGB_CAPABLE          #x0002100E)
  (define GLFW_REFRESH_RATE          #x0002100F)
  (define GLFW_DOUBLEBUFFER          #x00021010)

  (define GLFW_CLIENT_API            #x00022001)
  (define GLFW_CONTEXT_VERSION_MAJOR #x00022002)
  (define GLFW_CONTEXT_VERSION_MINOR #x00022003)
  (define GLFW_CONTEXT_REVISION      #x00022004)
  (define GLFW_CONTEXT_ROBUSTNESS    #x00022005)
  (define GLFW_OPENGL_FORWARD_COMPAT #x00022006)
  (define GLFW_OPENGL_DEBUG_CONTEXT  #x00022007)
  (define GLFW_OPENGL_PROFILE        #x00022008)
  (define GLFW_CONTEXT_RELEASE_BEHAVIOR #x00022009)
  (define GLFW_CONTEXT_NO_ERROR      #x0002200A)
  (define GLFW_CONTEXT_CREATION_API  #x0002200B)

  (define GLFW_NO_API                          0)
  (define GLFW_OPENGL_API            #x00030001)
  (define GLFW_OPENGL_ES_API         #x00030002)

  (define GLFW_NO_ROBUSTNESS                   0)
  (define GLFW_NO_RESET_NOTIFICATION #x00031001)
  (define GLFW_LOSE_CONTEXT_ON_RESET #x00031002)

  (define GLFW_OPENGL_ANY_PROFILE              0)
  (define GLFW_OPENGL_CORE_PROFILE   #x00032001)
  (define GLFW_OPENGL_COMPAT_PROFILE #x00032002)

  (define GLFW_CURSOR                #x00033001)
  (define GLFW_STICKY_KEYS           #x00033002)
  (define GLFW_STICKY_MOUSE_BUTTONS  #x00033003)

  (define GLFW_CURSOR_NORMAL         #x00034001)
  (define GLFW_CURSOR_HIDDEN         #x00034002)
  (define GLFW_CURSOR_DISABLED       #x00034003)

  (define GLFW_ANY_RELEASE_BEHAVIOR            0)
  (define GLFW_RELEASE_BEHAVIOR_FLUSH #x00035001)
  (define GLFW_RELEASE_BEHAVIOR_NONE #x00035002)

  (define GLFW_NATIVE_CONTEXT_API    #x00036001)
  (define GLFW_EGL_CONTEXT_API       #x00036002)

  ;;! @defgroup shapes Standard cursor shapes
					;
					;  See [standard cursor creation](@ref cursor_standard) for how these are used.
					;
					;  @ingroup input
					;  @{ ;;

  ;;! @brief The regular arrow cursor shape.
					;
					;  The regular arrow cursor.
  ;;
  (define GLFW_ARROW_CURSOR          #x00036001)
  ;;! @brief The text input I-beam cursor shape.
					;
					;  The text input I-beam cursor shape.
  ;;
  (define GLFW_IBEAM_CURSOR          #x00036002)
  ;;! @brief The crosshair shape.
					;
					;  The crosshair shape.
  ;;
  (define GLFW_CROSSHAIR_CURSOR      #x00036003)
  ;;! @brief The hand shape.
					;
					;  The hand shape.
  ;;
  (define GLFW_HAND_CURSOR           #x00036004)
  ;;! @brief The horizontal resize arrow shape.
					;
					;  The horizontal resize arrow shape.
  ;;
  (define GLFW_HRESIZE_CURSOR        #x00036005)
  ;;! @brief The vertical resize arrow shape.
					;
					;  The vertical resize arrow shape.
  ;;
  (define GLFW_VRESIZE_CURSOR        #x00036006)
  ;;! @} ;;

  (define GLFW_CONNECTED             #x00040001)
  (define GLFW_DISCONNECTED          #x00040002)

  (define GLFW_DONT_CARE              -1)


  ;;begin glut function
  (define lib-name
    (case (machine-type)
      ((arm32le) "libglfw.so")
      ((a6nt i3nt ta6nt ti3nt)  "libglfw.dll")
      ((a6osx i3osx ta6osx ti3osx)  "libglfw.so")
      ((a6le i3le ta6le ti3le) "libglfw.so")))

  (define lib (load-lib lib-name))

  (define glfw-init 
    (foreign-procedure "glfwInit" () int ))
  
  (define glfw-window-hint 
    (foreign-procedure "glfwWindowHint" (int int) void ))

  (define glfw-create-window 
    (foreign-procedure "glfwCreateWindow" (int int string void* void* ) void* ))
  (define glfw-terminate 
    (foreign-procedure "glfwTerminate" () void ))

  (define $glfw-set-key-callback
    (foreign-procedure "glfwSetKeyCallback" (void* void*) void* ))

  (define glfw-make-context-current
    (foreign-procedure "glfwMakeContextCurrent" (void* ) void ))

  (define glfw-swap-interval
    (foreign-procedure "glfwSwapInterval" (int ) void ))

  (define $glfw-set-cursor-pos-callback
    (foreign-procedure "glfwSetCursorPosCallback" (void* void*) void*))

  (define $glfw-set-window-size-callback
    (foreign-procedure "glfwSetWindowSizeCallback" (void* void*) void*))

   (define $glfw-set-mouse-button-callback
    (foreign-procedure "glfwSetMouseButtonCallback" (void* void*) void*))

   (define $glfw-set-scroll-callback
     (foreign-procedure "glfwSetScrollCallback" (void* void*) void*))

    (define $glfw-set-joystick-callback
     (foreign-procedure "glfwSetJoystickCallback" (void* void*) void*))

     (define $glfw-set-char-callback
     (foreign-procedure "glfwSetCharCallback" (void* void*) void*))
    

     (define glfw-get-clipboard-string
       (foreign-procedure "glfwGetClipboardString" (void* ) string))
     

     (define glfw-set-clipboard-string
       (foreign-procedure "glfwSetClipboardString" (void* string ) void))
     
     
   (define glfw-wait-events
     (foreign-procedure "glfwWaitEvents" () void))

   (define glfw-create-standard-cursor
    (foreign-procedure "glfwCreateStandardCursor" (int) void*))

   (define glfw-create-cursor
     (foreign-procedure "glfwCreateCursor" (void* int int) void*))

   (define glfw-set-cursor
     (foreign-procedure "glfwSetCursor" (void* void*) void))

  (define (glfw-set-key-callback win fun)
    ($glfw-set-key-callback win (glfw-make-key-callback fun)))

  (define (glfw-set-cursor-pos-callback win fun)
    ($glfw-set-cursor-pos-callback win (glfw-make-cursor-pos-callback fun)  ))
  
  (define (glfw-set-window-size-callback win fun)
    ($glfw-set-window-size-callback win (glfw-make-window-size-callback fun)  ))

  (define (glfw-set-mouse-button-callback win fun)
    ($glfw-set-mouse-button-callback win (glfw-make-mouse-button-callback fun) ))

  (define (glfw-set-scroll-callback win fun)
    ($glfw-set-scroll-callback win (glfw-make-scroll-callback fun)))

  (define (glfw-set-char-callback win fun)
    ($glfw-set-char-callback win (glfw-make-char-callback fun)))
    
   (define (glfw-set-joystick-callback win fun)
    ($glfw-set-scroll-callback win (glfw-make-joystick-callback fun)))

   (define glfw-make-scroll-callback
    (lambda (p)
      (let ([code (foreign-callable p (void* double double) void)])
	(lock-object code)
	(foreign-callable-entry-point code))))


   (define glfw-make-joystick-callback 
     (lambda (p)
       (let ([code (foreign-callable p (void* int int ) void)])
	 (lock-object code)
	 (foreign-callable-entry-point code))))

   
  (define glfw-make-key-callback
    (lambda (p)
      (let ([code (foreign-callable p (void* int int   int  int) void)])
	(lock-object code)
	(foreign-callable-entry-point code))))

  (define glfw-make-cursor-pos-callback 
    (lambda (p)
      (let ([code (foreign-callable p (void* double double ) void)])
	(lock-object code)
	(foreign-callable-entry-point code))))

  (define glfw-make-window-size-callback 
    (lambda (p)
      (let ([code (foreign-callable p (void* int int ) void)])
	(lock-object code)
	(foreign-callable-entry-point code))))

  (define glfw-make-mouse-button-callback 
    (lambda (p)
      (let ([code (foreign-callable p (void* int int int ) void)])
	(lock-object code)
	(foreign-callable-entry-point code))))

   (define glfw-make-char-callback 
     (lambda (p)
       (let ([code (foreign-callable p (void*  int ) void)])
	 (lock-object code)
	 (foreign-callable-entry-point code))))
  
  ;;gladLoadGLLoader
  (define glfw-window-should-close
    (foreign-procedure "glfwWindowShouldClose" (void* ) int ))

  (define glfw-get-framebuffer-size
    (foreign-procedure "glfwGetFramebufferSize" (void* void* void*) void ))

  (define glfw-swap-buffers
    (foreign-procedure "glfwSwapBuffers" (void* ) void ))

  (define glfw-poll-events
    (foreign-procedure "glfwPollEvents" ( ) void ))

  (define glfw-destroy-window
    (foreign-procedure "glfwDestroyWindow" (void* ) void ))

  (define get-glfw-get-proc-address
    (foreign-procedure "getGlfwGetProcAddress" ( ) void* ))

  ;;glad
  (define glad-load-gl
    (foreign-procedure "gladLoadGL" ( ) int ))
  (define glad-load-gl-loader
    (foreign-procedure "gladLoadGLLoader" (void*) int ))

  (define glad-load-gles2-loader
    (foreign-procedure "gladLoadGLES2Loader" (void* ) int ))

  (define glad-load-gles1-loader
    (foreign-procedure "gladLoadGLES1Loader" (void* ) int ))


  )
