# How to build a module

### Overview
Building a module or repackaging existing code into one is made quite easy in TALOS.  We only have a few requirements for a script to be considered module ready.  Meet the requirements and you're good to go.  Of course, there are always more *optional* things you can do to increase the extensibility or power of your module.

### Requirements
1. A meta section
2. A properly formatted dictionary called *variables*
3. A class containing relevant commands, called *commands*
..* For backgrounding support, a command called *run*

### Meta section
Your module must contain a meta variable \(a python dictionary type variable in the root scope of your module.\)
Here are the currently supported keys \(and their type\).
+ author -- \<string\>
+ ported_by -- \<string\>
+ version -- \<string\>
+ info -- \<string\>

You are going to need these four items in your module's meta string in order to make sure it runs properly.
The info string is very important.  As it should contain all the information a new user will need to know about your module upon first viewing it.  This is the string that is read to the user when they run the command `help <module>` with <module> = your module's name.
Please consider putting a decent high level summary of your tool in this string.

### Properly formatted variables' dictionary
Your module must contain a properly formated variables' dictionary.  This is the way in which the module and the main script communicate to fulfill the configuration requirements for the module's execution.
Here's what it should look like.  It should be a dictionary type variable.  Named *variables* and located near the beginning of your module for ease of access.  It should be a global variable in your module.  The format of the variable is as follows.
Every entry in the dictionary should be formatted as so.  The key should be the name of the variable.  The value should be a *list* containing three items.  The first entry in the list should contain the value of the variable.  \(set this ahead of time if you want to have a default value\).  The second entry should contain either the word "yes" or the word "no" and determines if the variable is required to be set before execution can commence.  The third entry in the list should contain a brief description of the variable.  If a brief description is not possible, go ahead and write up whatever you need to.  It will be replaced by a "too_long" message.  And require the user to type the command *more <variable>* to view the full description.  
It is important to note that all the entries in this list should be strings. \(python:str\)
Here is what a variable's dictionary should look like. \(From: local/honeyports/basic \)
```python
variables = {"host":["","no","Leave blank for 0.0.0.0 'all'"],"port":["","yes","port to listen on"],"whitelist":["127.0.0.1,8.8.8.8","no","hosts to whitelist (cannot be blocked)"]}

```
### A class with all your commands
Any commands you want the user to be able to run must be built into the module inside of a class named *commands*.
The default name for a module specific command is *run*.  This would be built into your *commands* class as a method with the name *run*.  
Since it is assumed that you will be needing the values for the requested variables as set by the user, all commands are required to take as their input variables an instance of the class commands, and a copy of the variables dictionary.
It is also important to note that whatever functions you choose to use, they must be static methods.
This will look something like this when you're writing it.
```python
class commands:
	def __init__(self):
		return
	
	@staticmethod
	def run(self, variables):
		my_var = variables['my_var'][0]
		execute_my_module(my_var)
```

It is the job of your module specific commands to convery the values stored  in the variables dictionary back into whatever format your module needs them in.  It is also the job of your module specific commands to wrap together and execute your module using whatever methods or functions are necessary for such a task. 

##### Backgrounding
Though you are always welcome to background your own module/commands in whatever way you see fit.  TALOS comes with a built in background \(multiprocessing\) function which launches commands in the background at the request of the user.  The command for the user to launch a module in the background is *run -j*.  However, it requires the existence of a *run* command in the specific module the user is attempting to execute.  
So if you want users to be able to use the built in backgrounding in TALOS please have a command with the name *run* that is background \(multiprocessing\) compatible.

### Optional includes
I'm currently working on adding more optional includes functionality.  As well as ways to make module writing quicker, simpler, and far more powerful.  For now, we only have one thing, and that is notifications.
If you want your module to be able to send notifications, you're gonna need to do this.
Import the proper function.
```python
from core.logging import log_notification
```
Then when you encounter something you want to notify the user about, send the message text to the user in the main TALOS console like so.
```python
log_notification("my message here")
```

If you want your module to perform queries against the talos database, just do something like this.
```python
from core.database import essential

e = essential()
e.db_exec("select * from requests")
```

We'll keep working to update and add more functionality as time continues.


