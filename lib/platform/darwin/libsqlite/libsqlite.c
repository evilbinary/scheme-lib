/*
#Copyright 2016-2080 littleblue.
#作者:littleblue on 3/19/17.
#邮箱:1075112523@qq.com
*/
#include <stdio.h>
#include "sqlite3.h"
#include "sqlite.h"
static int callback(void *NotUsed, int argc, char **argv, char **azColName);
int sqliteRun(char*file ,char *execute){
   sqlite3 *db;
    char *zErrMsg = 0;
  int rc;
   rc = sqlite3_open(file, &db);
   if( rc ){
     fprintf(stderr, "Can't open database: %s\n", sqlite3_errmsg(db));
     sqlite3_close(db);
      return(1);
    }
    rc = sqlite3_exec(db, execute, callback, 0, &zErrMsg);
   if( rc!=SQLITE_OK ){
     fprintf(stderr, "SQL error: %s\n", zErrMsg);
      sqlite3_free(zErrMsg);
    }
   sqlite3_close(db);
    return 0;
 }
 static int callback(void *NotUsed, int argc, char **argv, char **azColName){
     int i;
     for(i=0; i<argc; i++){
     }
    printf("\n");
     return 0;
  }
