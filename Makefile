

hello: hello.o
	gcc -o hello hello.o

hello.o:
	gcc -c hello.c

clean:
	rm hello.o hello
