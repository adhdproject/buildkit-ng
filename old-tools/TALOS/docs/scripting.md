#How to script TALOS

### Overview
The default method by which it is expected TALOS will usually be used, is via the TALOS shell (execute talos.py).  That being said.  When you need to run tasks in a more automated fashion.  We have a solution for that.  TALOS includes the ability to run scripted operations in a very simple and convenient way.

### The Process
1. Write up your script
2. Execute talos.py with the script specified

### Writing up your script
Now, we have tried to make this process as simple as can be.  Here's the deal.  All you need to do, it write up a file containing the commands you want to run.  In order, seperated by newlines.
So, every line should contain one command, and one command alone.
Here is an actual example of how you would code up the commands to run the module local/honeyports/basic on port 445
```
load local/honeyports/basic
set port 445
run
```
Save this to a file.  With an appropriate name.

### Executing talos.py with your script
The way in which one would execute the script is as follows.  Run talos.py with the *-s* or *--script* option.  Specifying the path to your saved script file.
Here is an example running one of the built in scripts.
```
python talos.py --script scripts/honeyport_basic_445
```

