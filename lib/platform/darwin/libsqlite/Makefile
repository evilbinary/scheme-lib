/*
#Copyright 2016-2080 littleblue.
#作者:littleblue on 3/19/17.
#邮箱:1075112523@qq.com
*/
TARGET = libsqlite.so
SOURCE = libsqlite.c shell.c sqlite3.c
$(TARGET): $(SOURCE)
	$(CC)  $(SOURCE) -shared  -o $(TARGET)

all:$(TARGET)
	cp libsqlite.so ../../../../bin
clean:
