TARGET = libsqlite.so
SOURCE = libsqlite.c shell.c sqlite3.c
$(TARGET): $(SOURCE)
	$(CC)  $(SOURCE) -shared  -o $(TARGET)

all:$(TARGET)
	cp libsqlite.so ../../../../bin
clean:
