#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>
#include <getopt.h>

#include <netdb.h>
#include <time.h>
#include <fcntl.h>
#include <signal.h>
#include <regex.h>

#include <sys/socket.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/select.h>
#include <sys/resource.h>

#include <net/if.h>
#include <arpa/inet.h>
#include <arpa/nameser_compat.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <netinet/tcp.h>
#include <netinet/udp.h>
#include <netinet/ip_icmp.h>


void main(int, char **);
void myexit(int, char *);
void accept_connections();
void sigexit();
void usage();
int send_payload(int, unsigned char *,int);

