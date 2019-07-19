@set LD_LIBRARY_PATH=.;..\packages\
@set path=%path%;%LD_LIBRARY_PATH%
@set LD_LIBRARY_PATH=%path%

@set CHEZSCHEMELIBDIRS=%path%
@set SCHEMEHEAPDIRS=.
@set SCHEME_LIBRARY_PATH=..\packages\slib\
@set CHEZ_IMPLEMENTATION_PATH=.\
scheme.exe --script ..\apps\%1.ss