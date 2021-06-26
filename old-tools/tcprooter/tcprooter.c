//-------------------------------------------------------------------
// Title......: TcpRo0ter
// Author.....: Joff Thyer
// Revisions..:
//      * Created on February 14, 2011
//      * Revised / license added July 2019
// Description:
//      This program binds as many TCP ports on a system as it can.
//      Port numbers start at zero and count up.
//      Upon connection to a TCP port, for fun, a Metasploit
//      payload can be transmitted.
//-------------------------------------------------------------------
//			
// Copyright (c) 2019, Joff Thyer
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:

// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#include "tcprooter.h"
#include "msfpayloads.h"

#define LISTENQ 16
#define TITLE	"TCP Ro0ter"
#define VERSION	"Version 1.1"
#define AUTHOR	"Author: Joff Thyer, Copyright (c) 2011-2019"

int msfpayload=0;
int maxports=10;
int sfd[65537];
extern int errno;

void main(int argc, char **argv)
{
    // exit signals
    signal(SIGINT, sigexit);
    signal(SIGTERM, sigexit);
    signal(SIGKILL, sigexit);

    int opt;
    while ((opt = getopt(argc, argv, "hn:m")) != -1)
    {
        switch (opt)
        {
            case 'n':
                maxports = atoi(optarg);
                break;
            case 'm':
                msfpayload = 1;
                break;
            case 'h':
            default:
                usage();
                break;
        }
    }
    // must be root to execute this thing
    if(geteuid() !=0) myexit(1,"You must be root to run this!");
    maxports = maxports > 65535 ? 65535 : maxports;

    struct rlimit rlim;
    if(getrlimit(RLIMIT_NOFILE,&rlim) <0) myexit(1,"getrlimit()");

    rlim.rlim_cur += maxports;
    rlim.rlim_max += maxports;
    if(setrlimit(RLIMIT_NOFILE,&rlim) <0) myexit(1,"setrlimit()");

    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);

    int port = 0;
    int ok = 0;
    int notok = 0;
    while(port++ < maxports )
    {
        sfd[port] = socket(AF_INET, SOCK_STREAM | SOCK_NONBLOCK, 0);
        if(sfd[port] < 0) myexit(1,"socket()");
        addr.sin_port = htons(port);

        int retval = bind(sfd[port],(struct sockaddr *)&addr, sizeof(addr));
        if(retval > -1 && listen(sfd[port],LISTENQ) > -1)
            ok++;
        else
        {
            sfd[port] = -1;
            notok++;
        }
    }

    printf("%s, %s\n%s\n",TITLE, VERSION, AUTHOR);
    printf("Listening on %d TCP ports from port 1 through %d.\n%d TCP ports in use by other processes.\nReady to accept connections!\n\nPress <ENTER> to exit.\n",ok,maxports,notok);
    accept_connections();
    myexit(0,"");
}


void accept_connections()
{
    int i, nfds;
    int retval;
    fd_set rdset;

    while(1)
    {
        // re-zero the socket set
        FD_ZERO(&rdset);
        FD_SET(0,&rdset);
        nfds=0;
        for(i=1;i<maxports;i++)
            if(sfd[i] > 0)
            {
                nfds = nfds > sfd[i] ? nfds : sfd[i];
                FD_SET(sfd[i],&rdset);
            }
        retval = select(nfds+1, &rdset, NULL, NULL, NULL);

        if(FD_ISSET(0,&rdset)) myexit(0,"");

        i=0;
        while(i++ < maxports)
        {
            if(FD_ISSET(sfd[i],&rdset))
            {
                int newcon = accept(sfd[i],NULL,NULL);
                if(msfpayload)
                    switch (sfd[i] % PAYLOADS)
                    {
                        case 0:
                            send_payload(newcon,linux_x86_shell_bind_tcp,
                                sizeof(linux_x86_shell_bind_tcp));
                            break;
                        case 1:
                            send_payload(newcon,osx_x86_shell_bind_tcp,
			                    sizeof(osx_x86_shell_bind_tcp));
                            break;
                        case 2:
                            send_payload(newcon,solaris_x86_shell_bind_tcp,
			                    sizeof(solaris_x86_shell_bind_tcp));
                            break;
                        case 3:
                            send_payload(newcon,windows_shell_bind_tcp,
			                    sizeof(windows_shell_bind_tcp));
                            break;
                        case 4:
                            send_payload(newcon,windows_x64_shell_bind_tcp,
			                    sizeof(windows_x64_shell_bind_tcp));
                            break;
                    }
                // close connection
                close(newcon);
            }
        }
    }
}


void usage()
{
    const char *text =
        "tcprooter -m -n <max port no>\n"
        "  -m: send a handful of metasploit payloads (modulus port number)\n"
        "  -n: total number of TCP sockets to listen on.\n";
    printf("%s %s %s\nUsage: %s\n", TITLE, VERSION, AUTHOR, text);
    myexit(0,"");
}

void sigexit()
{
    myexit(1,"");
}


void myexit(int code, char *errstr)
{
    if(strlen(errstr) > 0) perror(errstr);
  
    // close sockets
    int i=0;
    while(i++ < maxports)
        (sfd[i] > 0) && close(sfd[i]);
    exit(code);
}


int send_payload(int fd, unsigned char *payload, int size)
{
    return write(fd,payload,size);
}

