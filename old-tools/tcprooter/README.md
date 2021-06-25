# Tcpro0ter

This program attempts to listen on as many tcpports as it
can. It is single threaded, and thus when someone connects to
a port, the socket is immediately closed again.
When you run the program, it starts at TCP port zero and attempts
to bind each TCP port counting up to the maximum of 65535 or
the number specified on the command line.  It also has 5 different
Metasploit payloads compiled in which will be transmitted upon
port connection if the "-m" switch is specified.  Each payload
is selected using modulus the port number as the sockets are
created.

#Usage

    TCP Ro0ter Version 1.1 Author: Joff Thyer, Copyright (c) 2011-2019
    Usage: tcprooter -m -n <max port no>
        -m: send a handful of metasploit payloads (modulus port number)
        -n: total number of TCP sockets to listen on.

Author: Joff Thyer
Copyright (c) 2019

