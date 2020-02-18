all: server client

server: server.o
	gcc server.o -o server -pthread

server.o: server.c
	gcc -c server.c -O3 -Wall -pthread

client: client.o
	gcc client.o -o client -lrt

client.o: client.c
	gcc -c client.c -O3 -Wall -lrt

clean:
	rm -rf *o server
	rm -rf *o client
