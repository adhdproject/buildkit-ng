#Phantom

###What is Phantom?
Phantom is a long arm module for Talos.  Specifically, it is a tool which seeks to extend the range at which one may deply the modules contained within the framework.  

In practice, Phantom is somewhat akin to a type of "malware" for the good guys.  We use Phantom to do some of the same things that an attacker might write up some malware for.  Except in the end we serve the purpose of network defense, rather than pillage.

Phantom can be deployed to remote machines on your network, then used to push scripts from the local framework through to those remote hosts.

###What does that mean in practice?
In practice, the basic usage of Phantom is quite straight forward.  Run it on a host somewhere on the network other than where your command and control console is.  You can then have Phantom call back to your console, and can issue it commands from there.

###Give me an example
Here is an example of something you might use Phantom for.  Say you have been detecting strange activity on one of your edge routers, and believe a portion of your network might have been compromised.  You could deploy Phantom to a number of hosts in the segment in question, and use phantom to deploy talos modules (like honeyports) to automatically detect, and thwart attacks.

