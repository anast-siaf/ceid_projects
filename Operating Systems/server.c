#include <stdio.h>
#include <unistd.h>
#include <sys/types.h> 
#include <sys/socket.h> 
#include <errno.h> 
#include <sys/wait.h> 
#include <sys/un.h>
#include <stdlib.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <semaphore.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <time.h>
#include <pthread.h>

#include "global.h"

//Defining the length of the server's socket acceptance queue
#define LISTENQ 1500 
//Defining the size of the shared memory 1, shared memory 1 will store the number of call operators, termatika and available tickets of zones A, B, C and D
#define SHM_SIZE1 12*sizeof(int)

//Defining the size of the shared memory 2, shared memory 2 will store the booked seats of Zone A
#define SHM_SIZE2 ZONEA_SEATS*sizeof(int)
//Defining the size of the shared memory 3, shared memory 3 will store the booked seats of Zone B
#define SHM_SIZE3 ZONEB_SEATS*sizeof(int)
//Defining the size of the shared memory 4, shared memory 4 will store the booked seats of Zone C
#define SHM_SIZE4 ZONEC_SEATS*sizeof(int)
//Defining the size of the shared memory 5, shared memory 5 will store the booked seats of Zone D
#define SHM_SIZE5 ZONED_SEATS*sizeof(int)

//The key is defined by the settings of IPC
#define SHM_KEY1 IPC_PRIVATE
//The key is defined by the settings of IPC
#define SHM_KEY2 IPC_PRIVATE
//The key is defined by the settings of IPC
#define SHM_KEY3 IPC_PRIVATE
//The key is defined by the settings of IPC
#define SHM_KEY4 IPC_PRIVATE
//The key is defined by the settings of IPC
#define SHM_KEY5 IPC_PRIVATE

int sd, sockfd, pid, pid2, pid3;	// Declaration of the socket names sd, sockfd and of the process id (pid)
Message msg;	// used for messages between server and client
struct sockaddr addr, claddr;	//Declaration of socket addresses (server address, client address)
socklen_t addr_len, claddr_len;	//Declaration of the length of each address
int shm_id[5], error[10];	//ids for shared memories

struct itimerval itv;

//The pointer *num points to the shared memory which contains the number of available call operators and the bank operators
int *num;
int *zone_id[4];
//my_sem is the semaphore used to control access to the shared memory
#define SEM_NAME "my_semaphore"
#define SEM_COMPANY_NAME "company_semaphore"
#define SEM_BANK_NAME "bank_semaphore"
sem_t *my_sem;
sem_t *company_sem;
sem_t *bank_sem;

void print_plane( void )
{
  int i, j;
  for (j = 0; j < 4; j++ )
  {
    i = 1;
    
    printf("Zone %c: [", zoneletter[j]);
    if (*(zone_id[j]) != -1) printf("%d", *(zone_id[j]));
      
    while (*(zone_id[j] + i) != -1)
    {
	printf(", %d", *(zone_id[j] + i));
	i++;
    }
    printf("]\n");
  }
  printf("%d - %d\n", *(num+6) - *(num+7), *(num+6) );
  printf("Unsuccessful bookings: %.2f%%\n", ((((float)*(num+6) - (float)*(num+7))/(float)(*(num+6)))*100));
  printf("Total income: %d Euros\n", *num + *(num + 1));
}
    

//Signal function which kills zombie processes created by the function fork() and did not close correctly
void sig_chld( int sig_num ){ 
    pid_t pid;
    int stat;
	
    while ( ( pid = waitpid( -1, &stat, WNOHANG ) ) > 0 ){
        printf( "Child %d terminated %d.\n", pid, sig_num );
    }
}

// Signal function that checks periodically whether an order is delayed 
// if a process is still active after t_wait, a sorry message is sent to the client
// this can happen more than once for every process 
void signal_handler (int sig_num){
	strcpy(msg.buf, SORRY);
	write(sockfd, &msg, sizeof(Message));
}



void endserver(int sig_num)
{
	int i;
	
	print_plane();
	
	error[0] = shmdt(num);	//Trying to detach from the shared memory of counters
	if( error[0] == -1){
		printf("Could not detach from shared memory for counters!\n");
		exit(1);
	}
	
	error[5] = shmctl(shm_id[0], IPC_RMID, NULL);
	if( error[5] == -1){
		printf("Could not delete from shared memory for counters!\n");
		exit(1);
	}
	
	for (i=0; i<4; i++)
	{
	  error[i+1] = shmdt(zone_id[i]);	//Trying to detach from the shared memory of Zones
	  if( error[i+1] == -1){
		printf("Could not detach from shared memory for Zone %c booking!\n", zoneletter[i]);
		exit(1);
	  }
	  
	  error[i+6] = shmctl(shm_id[i+1], IPC_RMID, NULL);
	  if( error[i+6] == -1){
		printf("Could not delete shared memory for Zone %c booking!\n", zoneletter[i]);
		exit(1);
	  }
	}
	
	//close semaphores
	sem_close(my_sem);
	sem_close(company_sem);
	sem_close(bank_sem);
	sem_unlink(SEM_NAME);
	sem_unlink(SEM_COMPANY_NAME);
	sem_unlink(SEM_BANK_NAME);
	
	//the cleanup of the socket cd and exit from the process.
	close(sd);
}

int main(void){
	int i, j, taken_seats, avail_seats;
	itv.it_interval.tv_usec = 0;
	itv.it_interval.tv_sec = t_wait;
	itv.it_value.tv_usec = 0;
	itv.it_value.tv_sec = t_wait;

	//Start Signals
	signal( SIGCHLD, sig_chld ); 	
	signal( SIGALRM, signal_handler );
	signal(SIGINT, endserver);
	
	printf("Server has begun.\n");
	//Creating socket with the name sd
	sd = socket(AF_UNIX, SOCK_STREAM, 0);	
	
	printf("Socket has been created.\n");


	//creating shared memory 1 with key = SHM_KEY1 and size =SHM_SIZE1
	//if the shared memory cannot be created then print an error message
	shm_id[0] = shmget(SHM_KEY1, SHM_SIZE1, 0600 | IPC_CREAT); 
	if(shm_id[0] < 0){
		printf("Did not create shared memory for counters!\n");
		printf("%d", errno);
		exit(1);
	}

	//creating shared memory 2 with key = SHM_KEY2 and size =SHM_SIZE2
	//if the shared memory cannot be created then print an error message
	shm_id[1] = shmget(SHM_KEY2, SHM_SIZE2, 0600 | IPC_CREAT); 
	if(shm_id[1] < 0){
		printf("Did not create shared memory for Zone A booking!\n");
		printf("%d", errno);
		exit(1);
	}
	
	//creating shared memory 3 with key = SHM_KEY3 and size =SHM_SIZE3
	//if the shared memory cannot be created then print an error message
	shm_id[2] = shmget(SHM_KEY3, SHM_SIZE3, 0600 | IPC_CREAT); 
	if(shm_id[2] < 0){
		printf("Did not create shared memory for Zone B booking!\n");
		printf("%d", errno);
		exit(1);
	}

	//creating shared memory 4 with key = SHM_KEY4 and size =SHM_SIZE4
	//if the shared memory cannot be created then print an error message
	shm_id[3] = shmget(SHM_KEY4, SHM_SIZE4, 0600 | IPC_CREAT); 
	if(shm_id[3] < 0){
		printf("Did not create shared memory for Zone C booking!\n");
		printf("%d", errno);
		exit(1);
	}

	//creating shared memory 5 with key = SHM_KEY5 and size =SHM_SIZE5
	//if the shared memory cannot be created then print an error message
	shm_id[4] = shmget(SHM_KEY5, SHM_SIZE5, 0600 | IPC_CREAT); 
	if(shm_id[4] < 0){
		printf("Did not create shared memory for Zone D booking!\n");
		printf("%d", errno);
		exit(1);
	}


	// attach to shared memory 1
	num = (int*) shmat(shm_id[0], NULL, 0);	
	*(num) = 0; //Company account
	*(num+1) = 0; //Theater account
	*(num+2) = ZONEA_SEATS;
	*(num+3) = ZONEB_SEATS;
	*(num+4) = ZONEC_SEATS;
	*(num+5) = ZONED_SEATS;

	*(num+6) = 0; //Transactions
	*(num+7) = 0; //Successful Transactions

	*(num+8) = 0; //Seats taken ZoneA
	*(num+9) = 0; //Seats taken ZoneB
	*(num+10) = 0; //Seats taken ZoneC
	*(num+11) = 0; //Seats taken ZoneD

	for (i=0; i<4; i++)//attach to shared memory 3,4,5 & 6
	{
		zone_id[i] = (int *)shmat(shm_id[i+1], NULL, 0);

		for (j=0; j<zoneseats[i]; j++)//initialization of shared memory
		{
			*(zone_id[i] + j) = -1;
		}
	}
	
	//Create semaphore and set name as my_sem
	//if semaphore cannot be created then print an error message	
	my_sem = sem_open (SEM_NAME, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR, 1); 
	if(my_sem == SEM_FAILED){
		perror("Could not open semaphore!\n");
		exit(1);
	}
	
	company_sem = sem_open (SEM_COMPANY_NAME, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR, N_COMPANY); 
	if(company_sem == SEM_FAILED){
		perror("Could not open semaphore!\n");
		exit(1);
	}
	
	bank_sem = sem_open (SEM_BANK_NAME, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR, N_BANK); 
	if(bank_sem == SEM_FAILED){
		perror("Could not open semaphore!\n");
		exit(1);
	}
	
	//free file path "unipath" so that the socket address can be associated with it 
	//without confusing connection with sockets already made with this path
	unlink("unipath"); 
	bzero(&addr, sizeof(addr)); //set values of addr to zero
	addr.sa_family = AF_UNIX; //set the socket as a local unix based socket
	strcpy(addr.sa_data, "unipath");
	
	//bind the socket name sd with the socket address addr and if the binding fails print an error message
	if( bind(sd, (struct sockaddr *)&addr, sizeof(addr)) < 0){
		printf("server bind failure %d \n", errno);
		perror("Server: ");
		exit(1);
	}
	
	printf("Socket has been binded.\n");
	
	//start listening for socket connections with clients, puting connection in the listening queue with maximum size 1500
	if(listen(sd,LISTENQ) < 0){				//Checking if the server is listening to the client:
		printf("server listen failure %d \n", errno);	//If the server is not in position to listen to the client
		perror("Server: \n");				//sends an error message and exits the program.
		exit(1);					
	}
	
	printf("Server is listening...\n");			//If the server is in position to listen to the client it
	pid3 = fork();
	if (pid3 == 0)
	{
		signal(SIGINT, exit);
		while (1)
		{
			sleep(t_transfer);
			sem_wait(my_sem);
			*(num + 1) += *(num);
			printf("%d Euros deposited to bank.\n", *(num));
			*(num) = 0;
			sem_post(my_sem);
		}
	}
								
	while(1){						//Here starts an infinite loop in order for the server to
								//accept new clients
		claddr_len = sizeof(claddr);			//The address of the client
		
		// accept new connections
		sockfd = accept(sd, (struct sockaddr *)&claddr, &claddr_len);
		//if the server does not accept the client
		if ( sockfd < 0 ){
            		printf("server accept failure %d \n", errno);	//If the server is not in position to accept new connections
			perror("Server: \n");									//sends an error message and exits the program.
			exit(1);
       		 }	
			
		printf("Server has accepted a connection.\n");	//else it shows this message and continues to create
		
		pid = fork();					//more children procedures with the function fork()
		if(pid == 0){
			// start signal handler for each new process
			signal( SIGALRM, signal_handler );

			printf("Child proccess has been created.\n");
			*(num+6) += 1;
			// setitimer produces a signal (SIGALRM) every t_wait time
			setitimer(ITIMER_REAL, &itv, NULL);

			// once there is an available call operator we lock a semaphore again
			sem_wait(company_sem);
			
			
			//Stop "sorry" messages
			signal( SIGALRM, SIG_IGN );
			
			//Waits for the client to send the order the server will executes
			strcpy(msg.buf, ANSWER);
			write(sockfd, &msg, sizeof(Message));

			read(sockfd, &msg, sizeof(Message));
			
			// Add one transaction
			sem_wait(my_sem);
			
			sem_post(my_sem);

			pid2 = fork();
			if (pid2 == 0)
			{
				// once there is an available terminal we lock a semaphore again
				sem_wait(bank_sem);
				sleep(t_cardcheck);
				// once we are done we make a terminal available by unlocking a semaphore
				sem_post(bank_sem);
				
				close(sockfd);
				exit(EXIT_SUCCESS);
			}

			sem_wait(my_sem);
			avail_seats = *(num+2+msg.par.charge_zone);

			if (msg.par.credit_card == 0)// in the case the credit card in invalid
			{
				strcpy(msg.buf, "H pistotikh karta den einai egkyrh.");
			}
			else if (avail_seats >= msg.par.num_tickets)
			{
				*(num+2+msg.par.charge_zone) = *(num+2+msg.par.charge_zone) - msg.par.num_tickets;
				taken_seats = zoneseats[msg.par.charge_zone] - avail_seats;

				client_id = *(num+7) + 1;
				*(num+7) += 1;
				for (i=0; i<msg.par.num_tickets; i++)
				{
					*(zone_id[msg.par.charge_zone] + taken_seats + i) = client_id;
				}

				*(num) += msg.par.num_tickets*zoneprice[msg.par.charge_zone];

				sem_post(my_sem);

				sprintf(tempbuf2, "H krathsh oloklhrwthike epityxws. To anagnwristiko ths krathshs einai %03d,",
					client_id);
				
				sprintf(tempbuf, " oi theseis sas einai oi %c%d", zoneletter[msg.par.charge_zone],
					zoneseats[msg.par.charge_zone] - avail_seats + 1);
				strcat(tempbuf2, tempbuf);
				
				for (i = 0; i < msg.par.num_tickets - 1; i++)
				{
					sprintf(tempbuf, ", %c%d", zoneletter[msg.par.charge_zone],
						zoneseats[msg.par.charge_zone] - avail_seats + i + 2);
					strcat(tempbuf2, tempbuf);
				}

				sprintf(tempbuf, " kai to kostos ths synallaghs einai %d eyrw.",
					msg.par.num_tickets*zoneprice[msg.par.charge_zone]);
				strcat(tempbuf2, tempbuf);
				strcpy(msg.buf, tempbuf2);
			}
			else
			{
				if (*(num+2) + *(num+3) + *(num+4) + *(num+5) == 0)
					strcpy(msg.buf, "Den yparxoun katholou diathesimes theseis.");
				else
					strcpy(msg.buf, "Den yparxoun diathesimes theseis gia ti sygkekrimeni zwni.");

				sem_post(my_sem);
			}

			//Wait till search is over (t_seatfind)
			sleep(t_seatfind);
			//Wait card check process to finish, as well (parallel)
			waitpid(0, NULL, 0);

			write(sockfd, &msg, sizeof(Message));

			// after hang up, the number of busy call operators is decreased by one
			sem_post(company_sem);

			//the child process closes the the socket sockfd so nothing is left after the child process exits
			close(sockfd);		
			//after the child process is finished it exits, free any memory space used by it	
			exit(0);			
		}
		//the father process closes the socket fd immediately 
		// and returns to a state of waiting to accept a connection with another client
		close(sockfd);
	}
}
