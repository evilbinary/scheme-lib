(library (dffi dynload)
  (export
   dlLoadLibrary
   dlFreeLibrary
   dlFindSymbol
   dlGetLibraryPath
   dlSymsInit
   dlSymsCleanup
   dlSymsCount
   dlSymsName
   dlSymsNameFromValue
   )
  (import  (scheme) (utils libutil) (utils macro)  )
  (define lib-name
    (case (machine-type)
      ((arm32le) "libdffi.so")
      ((a6nt i3nt ta6nt ti3nt)  "libdffi.dll")
      ((a6osx ta6osx i3osx ti3osx)  "libdffi.so")
      ((a6le i3le ta6le ti3le) "libdffi.so")))
  (define lib (load-lib lib-name))

  
  (define dlLoadLibrary (foreign-procedure "dlLoadLibrary" (string) void*))
  (define dlFreeLibrary (foreign-procedure "dlFreeLibrary" (void*) void))
  (define dlFindSymbol (foreign-procedure "dlFindSymbol" (void* string) void*))
  (define dlGetLibraryPath (foreign-procedure "dlGetLibraryPath" (void* string int) int))


  (define dlSymsInit (foreign-procedure "dlSymsInit" ( string ) void*))
  (define dlSymsCleanup (foreign-procedure "dlSymsInit" ( void* ) void))
  (define dlSymsCount (foreign-procedure "dlSymsCount" ( void* ) int))
  (define dlSymsName (foreign-procedure "dlSymsName" ( void* int) string))
  (define dlSymsNameFromValue (foreign-procedure "dlSymsNameFromValue" ( void* void* ) string))
  
  
  )
