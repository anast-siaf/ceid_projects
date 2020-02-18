#include <stdio.h>
#include <unistd.h>
#include <sys/socket.h> /** basic socket definitions **/
#include <sys/types.h> /** basic system data types **/
#include <sys/un.h> /** for Unix domain sockets **/
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <time.h>
#include "global.h"

int cd; // variable used as a client Socket Descriptor
struct sockaddr addr; // define the struct where the address of the socket will be stored
Message Msg; // used for messages between server and client

void menu(void);

// function main

int main(int argc, char *argv[])
{
	puts("Welcome to tickethour.com");
	
	// create socket with ID = cd 
	cd = socket(AF_UNIX, SOCK_STREAM,0);
	//check if socket cd opened correctly
	if (cd <0){
		printf("Error opening socket!\n");
	}
	
	// bzero initializes to zero the content of addr 
	bzero(&addr, sizeof(addr));
	// initialize addr with appropriate values
	addr.sa_family = AF_UNIX;
	strcpy(addr.sa_data, "unipath");
	
	// with the use of socket cd, client connects to server
	if(connect(cd, (struct sockaddr *)&addr, sizeof(addr)) < 0){	
	// if the connection between server and client fails
	//an appropriate error message is printed the error message contains a number which is unique for the error that occurred
		printf("client connect failure %d\n", errno);
		// the kind of error is printed here		
		perror("Client: \n");
		// exit the program 
		exit(1);
	}
	
	// if no error has occured then the client has connected to server
	printf("Client has connected to server\n");

      
	// if so, say sorry message
	do{
		read(cd, &Msg, sizeof(Message));
		puts(Msg.buf);
	}while(!strcmp(Msg.buf, SORRY));

	
	//assign user arguments to message
	if (argc==1 || argc == 2)
		menu();
	else{
		Msg.par.num_tickets = atoi(argv[1]); // the number of tickets ordered
		Msg.par.charge_zone = atoi(argv[2]); // the cost zone of tickets ordered

		if (Msg.par.num_tickets < 1) Msg.par.num_tickets = 1;
		if (Msg.par.num_tickets > 4) Msg.par.num_tickets = 4;
		if (Msg.par.charge_zone < 1) Msg.par.charge_zone = 1;
		if (Msg.par.charge_zone > 4) Msg.par.charge_zone = 4;
	}

	srand(time(NULL));
	Msg.par.credit_card = rand()%10;
	if (Msg.par.credit_card) Msg.par.credit_card = 1;
	Msg.par.charge_zone -= 1;
	// send order to server
	write(cd,&Msg,sizeof(Message));	

	read(cd, &Msg, sizeof(Message));
	printf("%s\n", Msg.buf);

	// disconnects this client from server and closes the cd
	//so all connections are closed and there is no redundant use of memory	
	close(cd);
	// close this client with success
	exit(0);
}


// function that gets input from user
void menu(void){
	do{	
		printf("How many tickets do you want [1-4]? Choose:\n");
		printf("Enter your choice here: \n");
		// the user inserts his/her selection
		scanf("%d", &Msg.par.num_tickets);
	}while (Msg.par.num_tickets<1 || Msg.par.num_tickets>4);//while loop that doesn't allow use to make an invalid selection about the number of tickets.
	
	
	do{
		printf("In which charge zone [1-4]? Choose:\n");
		printf("1. Zone A\n2. Zone B\n3. Zone C\n4. Zone D\nEnter your choice here: ");
		scanf("%d", &Msg.par.charge_zone);
	}while(Msg.par.charge_zone<1 || Msg.par.charge_zone>4);// while-loop that does't allow the user to make an invalid selection about the charge zone.
}

