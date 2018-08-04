/**
 * 作者:evilbinary on 12/24/16.
 * 邮箱:rootdebug@163.com 
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "scm.h"

#define VERSION 2.1
char *ver="Scheme Version 2.1\n\
Copyright 2016-2020 evilbinary.\n\n";

void repl(){
  ptr op=scm_read_string(">");
    for (;;) {
      scm_call1("display",op);

      ptr exp = scm_call0("read");
      if (scm_objectp(exp)) 
        break;
      ptr p = scm_eval_exp(exp);
      if (p != scm_void){
        scm_call1("pretty-print", p);
      }

    }
    
}


void process_arg(int argc,char * argv[]){
  int n, new_argc = 1;
#ifdef SAVEDHEAPS
  int compact = 1, savefile_level = 0;
  const char *savefile = (char *)0;
#endif /* SAVEDHEAPS */
  const char *execpath = argv[0];
  const char *scriptfile = (char *)0;
  const char *programfile = (char *)0;
  const char *libdirs = (char *)0;
  const char *libexts = (char *)0;
  int status;
  const char *arg;
  int quiet = 0;
  int eoc = 0;
  int optlevel = 0;
  int debug_on_exception = 0;
  int import_notify = 0;
  int compile_imported_libraries = 0;
#ifdef FEATURE_EXPEDITOR
  int expeditor_enable = 1;
  const char *expeditor_history_file = "";  /* use "" for default location */
#endif /* FEATURE_EXPEDITOR */

  for (n = 1; n < argc; n += 1) {
      char *arg = argv[n];
      if (strcmp(arg,"--") == 0) {
        while (++n < argc) argv[new_argc++] = argv[n];
      } else if (strcmp(arg,"-b") == 0 || strcmp(arg,"--boot") == 0) {
        if (++n == argc) {
          (void) fprintf(stderr,"%s requires argument\n", arg);
          exit(1);
        }
        Sregister_boot_file(argv[n]);
      } else if (strcmp(arg,"--eedisable") == 0) {
  #ifdef FEATURE_EXPEDITOR
        expeditor_enable = 0;
  #endif /* FEATURE_EXPEDITOR */
      } else if (strcmp(arg,"--eehistory") == 0) {
        if (++n == argc) {
          (void) fprintf(stderr,"%s requires argument\n", arg);
          exit(1);
        }
  #ifdef FEATURE_EXPEDITOR
        if (strcmp(argv[n], "off") == 0)
          expeditor_history_file = (char *)0;
        else
          expeditor_history_file = argv[n];
  #endif /* FEATURE_EXPEDITOR */
      } else if (strcmp(arg,"-q") == 0 || strcmp(arg,"--quiet") == 0) {
        quiet = 1;
      } else if (strcmp(arg,"--retain-static-relocation") == 0) {
        Sretain_static_relocation();
      } else if (strcmp(arg,"--enable-object-counts") == 0) {
        eoc = 1;
#ifdef SAVEDHEAPS
      } else if (strcmp(arg,"-c") == 0 || strcmp(arg,"--compact") == 0) {
        compact = !compact;
      } else if (strcmp(arg,"-h") == 0 || strcmp(arg,"--heap") == 0) {
        if (++n == argc) {
          (void) fprintf(stderr,"%s requires argument\n", arg);
          exit(1);
        }
        Sregister_heap_file(argv[n]);
      } else if (strncmp(arg,"-s",2) == 0 &&
                 (savefile_level = -2,
                  *(arg+2) == 0 ||
                  *(arg+3) == 0 &&
                  ((savefile_level = *(arg+2) - '+' - 1) == -1 ||
                    (savefile_level = *(arg+2) - '0') >= 0 &&
                     savefile_level <= 9)) ||
                 strncmp(arg,"--saveheap",10) == 0 &&
                 (savefile_level = -2,
                  *(arg+10) == 0 ||
                  *(arg+11) == 0 &&
                  ((savefile_level = *(arg+2) - '+' - 1) == -1 ||
                    (savefile_level = *(arg+10) - '0') >= 0 &&
                     savefile_level <= 9))) {
        if (++n == argc) {
          (void) fprintf(stderr,"%s requires argument\n", arg);
          exit(1);
        }
        savefile = argv[n];
#else /* SAVEDHEAPS */
      } else if (strcmp(arg,"-c") == 0 || strcmp(arg,"--compact") == 0) {
        fprintf(stderr, "-c and --compact options are not presently supported\n");
        exit(1);
      } else if (strcmp(arg,"-h") == 0 || strcmp(arg,"--heap") == 0) {
        fprintf(stderr, "-h and --heap options are not presently supported\n");
        exit(1);
      } else if (strncmp(arg,"-s",2) == 0 || strncmp(arg,"--saveheap",10) == 0) {
        fprintf(stderr, "-s and --saveheap options are not presently supported\n");
        exit(1);
#endif /* SAVEDHEAPS */
      } else if (strcmp(arg,"--script") == 0) {
        if (++n == argc) {
          (void) fprintf(stderr,"%s requires argument\n", arg);
          exit(1);
        }
        scriptfile = argv[n];
        while (++n < argc) argv[new_argc++] = argv[n];
      } else if (strcmp(arg,"--optimize-level") == 0) {
        const char *nextarg;
        if (++n == argc) {
          (void) fprintf(stderr,"%s requires argument\n", arg);
          exit(1);
        }
        nextarg = argv[n];
        if (strcmp(nextarg,"0") == 0)
          optlevel = 0;
        else if (strcmp(nextarg,"1") == 0)
          optlevel = 1;
        else if (strcmp(nextarg,"2") == 0)
          optlevel = 2;
        else if (strcmp(nextarg,"3") == 0)
          optlevel = 3;
        else {
          (void) fprintf(stderr,"invalid optimize-level %s\n", nextarg);
          exit(1);
        }
      } else if (strcmp(arg,"--debug-on-exception") == 0) {
        debug_on_exception = 1;
      } else if (strcmp(arg,"--import-notify") == 0) {
        import_notify = 1;
      } else if (strcmp(arg,"--libexts") == 0) {
        if (++n == argc) {
          (void) fprintf(stderr,"%s requires argument\n", arg);
          exit(1);
        }
        libexts = argv[n];
      } else if (strcmp(arg,"--libdirs") == 0) {
        if (++n == argc) {
          (void) fprintf(stderr,"%s requires argument\n", arg);
          exit(1);
        }
        libdirs = argv[n];
      } else if (strcmp(arg,"--compile-imported-libraries") == 0) {
        compile_imported_libraries = 1;
      } else if (strcmp(arg,"--program") == 0) {
        if (++n == argc) {
          (void) fprintf(stderr,"%s requires argument\n", arg);
          exit(1);
        }
        programfile = argv[n];
        while (++n < argc) argv[new_argc++] = argv[n];
      } else if (strcmp(arg,"--help") == 0) {
        fprintf(stderr,"usage: %s [options and files]\n", execpath);
        fprintf(stderr,"options:\n");
        fprintf(stderr,"  -q, --quiet                             suppress greeting and prompt\n");
        fprintf(stderr,"  --script <path>                         run as shell script\n");
        fprintf(stderr,"  --program <path>                        run rnrs program as shell script\n");
#ifdef WIN32
#define sep ";"
#else
#define sep ":"
#endif
        fprintf(stderr,"  --libdirs <dir>%s...                     set library directories\n", sep);
        fprintf(stderr,"  --libexts <ext>%s...                     set library extensions\n", sep);
        fprintf(stderr,"  --compile-imported-libraries            compile libraries before loading\n");
        fprintf(stderr,"  --import-notify                         enable import search messages\n");
        fprintf(stderr,"  --optimize-level <0 | 1 | 2 | 3>        set optimize-level\n");
        fprintf(stderr,"  --debug-on-exception                    on uncaught exception, call debug\n");
        fprintf(stderr,"  --eedisable                             disable expression editor\n");
        fprintf(stderr,"  --eehistory <off | path>                expression-editor history file\n");
        fprintf(stderr,"  --enable-object-counts                  have collector maintain object counts\n");
        fprintf(stderr,"  --retain-static-relocation              keep reloc info for compute-size, etc.\n");
        fprintf(stderr,"  -b <path>, --boot <path>                load boot file\n");
//        fprintf(stderr,"  -c, --compact                           toggle compaction flag\n");
//        fprintf(stderr,"  -h <path>, --heap <path>                load heap file\n");
//        fprintf(stderr,"  -s[<n>] <path>, --saveheap[<n>] <path>  save heap file\n");
        fprintf(stderr,"  --verbose                               trace boot/heap search process\n");
        fprintf(stderr,"  --version                               print version and exit\n");
        fprintf(stderr,"  --help                                  print help and exit\n");
        fprintf(stderr,"  --                                      pass through remaining args\n");
        exit(0);
      } else if (strcmp(arg,"--verbose") == 0) {
        Sset_verbose(1);     
      } else if (strcmp(arg,"--version") == 0) {
        fprintf(stderr,"%s\n", VERSION);
        exit(0);
      } else {
        argv[new_argc++] = arg;
      }
    }
  scm_call1("suppress-greeting", scm_true);
  if (quiet) {
    
    //scm_call1("waiter-prompt-string", Sstring(""));
  }else{
    printf(ver);
  }
  if (eoc) {
    scm_call1("enable-object-counts", scm_true);
  }
  if (optlevel != 0) {
    scm_call1("optimize-level", Sinteger(optlevel));
  }
  if (debug_on_exception != 0) {
    scm_call1("debug-on-exception", scm_true);
  }
  if (import_notify != 0) {
    scm_call1("import-notify", scm_true);
  }
  //if (libdirs == 0) libdirs = getenv("CHEZSCHEMELIBDIRS");
  if (libdirs != 0) {
    scm_call1("library-directories", Sstring(libdirs));
  }
  if (libexts == 0) libexts = getenv("CHEZSCHEMELIBEXTS");
  if (libexts != 0) {
    scm_call1("library-extensions", Sstring(libexts));
  }
  if (compile_imported_libraries != 0) {
    scm_call1("compile-imported-libraries", scm_true);
  }
#ifdef FEATURE_EXPEDITOR
 /* Senable_expeditor must be called before Scheme_start/Scheme_script (if at all) */
  if (!quiet && expeditor_enable) Senable_expeditor(expeditor_history_file);
#endif /* FEATURE_EXPEDITOR */

  if (scriptfile != (char *)0)
   /* Sscheme_script invokes the value of the scheme-script parameter */
    status = Sscheme_script(scriptfile, new_argc, argv);
  else if (programfile != (char *)0)
   /* Sscheme_script invokes the value of the scheme-script parameter */
    status = Sscheme_program(programfile, new_argc, argv);
  else {
   /* Sscheme_start invokes the value of the scheme-start parameter */
    status = Sscheme_start(new_argc, argv);
    //repl();
  }


#ifdef SAVEDHEAPS
  if (status == 0 && savefile != (char *)0) {
      if (compact) Scompact_heap();
      Ssave_heap(savefile, savefile_level);
  }
#endif /* SAVEDHEAPS */

}


int main(int argc, const char *argv[]) {
    scm_init();

    process_arg(argc,argv);

    //ptr t=scm_read_string("(load \"/media/psf/workspace2/chez/app/src/packages/apps/imgui-test.ss\")");
    //scm_eval_exp(t);
    
    scm_deinit();
    return 0;
}
