#ifndef _MY_HEADER_
#define _MY_HEADER_

#define N_COMPANY 10
#define N_BANK     4

#define ZONEA_SEATS 100
#define ZONEB_SEATS 130
#define ZONEC_SEATS 180
#define ZONED_SEATS 230

#define SORRY "Sorry for the delay."
#define ANSWER "A call operator has answered."


const int t_seatfind = 6; //in seconds
const int t_cardcheck = 2; //in seconds


const int t_wait = 10;// time needed in order to decided whether to say "sorry" in seconds
int t_transfer = 30; //time needed in order to transfer money from company to theatre in seconds

int client_id = 0;// company client's id

char zoneletter[] = {'A', 'B', 'C', 'D'};
const int zoneseats[]  = {ZONEA_SEATS, ZONEB_SEATS, ZONEC_SEATS, ZONED_SEATS};
const int zoneprice[] ={50, 40, 35, 30};

// struct that stores orders, we keep the number of tickets, the charge zone of tickets and the credit card "number"
typedef struct{
	int num_tickets;
	int charge_zone;
	int credit_card;
} Book;


// struct that stores the messages sent between client and server
typedef struct{
	Book par;			
	char buf[256];			
} Message;

char tempbuf[256];
char tempbuf2[256];

#endif
