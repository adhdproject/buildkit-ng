#!/usr/bin/env python


from core.logging import log_notification

import core.depends
import time
outcd =core.depends.ppip()
if outcd[0]:
	log_notification("Dependencies were installed: %s" % outcd[1])

import core.conf
conf = core.conf.conf(core.conf.buildconf().confdict)

import argparse
import sys, os
from os import path
import imp
from multiprocessing import Process
import readline
import threading
import signal
import shlex
import subprocess

from twisted.internet import reactor
from core.backbone import _exec
from core.database import essential, dbadmin
from core.backbone import QU
from core.bootstrap import bootstrap
from core.passthrough import passthrough

qu = QU()

infostore = {
		'version':'1',
		'codename':'bootstrap',
		'contributors':['Benjamin Donnelly'],
		'sponsors':['Promethean Info Sec']
		}


variables = {}

vars_store = {}


notifications = []
current = ''
processes = []
threads = []

mapping_finame = "mapping"
ifstate = None

lastout = None
pausetime = 0.1

additional_aliases = {}

a_loaders = ["module ","load ","use ", "help "]
a_coms = ['invoke','purge','query','read','unload ','home ','show ','list ','quit','exit','run ','set ']
a_seconds = ['log','jobs','old','notifications','options','variables','commands','modules']

log_transcript = True
transcript = []

#Set debug to true on command line with --debug
DEBUG = False

if os.getuid() != 0:
	print
	print "-------------------------"
	print "Talos must be run as root"
	print "-------------------------"
	print 
	exit(-1)

def print_banner():
	subprocess.call("clear", shell=True)
	banner = """\n\n
####################################################
####################################################
########  _____ ___   _     _____ _____    #########
######## |_   _/ _ \ | |   |  _  /  ___|   #########
########   | |/ /_\ \| |   | | | \ `--.    #########
########   | ||  _  || |   | | | |`--. \   #########
########   | || | | || |___\ \_/ /\__/ /   #########
########   \_/\_| |_/\_____/\___/\____/    #########
########                                   #########
####################################################
########  Promethean Information Security  #########
####################################################
##         Welcome to TALOS Active Defense        ##
##             Type 'help' to begin               ##
####################################################\n
"""
	print banner
	return


def print_help():
	print "# Available commands"
	print "#  - help"
	print "#     A) help <module>"
	print "#     B) help <command>"
	print "#  - info"
	print "#  - list"
	print "#     A) list modules"
	print "#     B) list variables"
	print "#     C) list commands"
	print "#     D) list jobs"
	print "#     E) list inst_vars"
	print "#  - module"
	print "#     A) module <module>"
	print "#  - set"
	print "#     A) set <variable> <value>"
	print "#  - home"
	print "#  - query"
	print "#     A) query <sqlite query>"
	print "#  - read"
	print "#     A) read notifications"
	print "#     B) read old"
	print "#  - purge"
	print "#     A) purge log"
	print "#     B) purge transcript"
	print "#     C) purge db"
	print "#     D) purge db admin"
	print "#  - kill thread"
	print "#     A) kill thread <num>"
	print "#  - invoke"
	print "#     A) invoke <filename>"
	print "#  - update"
	print "#  - transcript"
	print "#     A) transcript <filename>"
	print "#     B) transcript !justprint!"
	print "#  - silence"
	print "#     A) silence list"
	print "#     B) silence add"
	print "#     C) silence del"
	print "#  - exit"

def check_updates():
	print "Attempting to check for updates via git"
	print "to disable this feature run talos with the --no-check flag"
	a, b = subprocess.Popen("git fetch --dry-run", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
	
	if len(b) > 4:
		print 
		print "--- Notice ---"
		print "Your version of TALOS is out of date."
		print "Please update at your earliest opportunity."


def did_you_mean(inp):
	poss = []

	for root, dirnames, filenames in os.walk("modules"):
		for filename in filenames:
			path = root + "/"
			path = path.split("modules/")[1]
			if not "pyc" in filename and is_module("modules/"+path+filename):
				for atte in inp.split("/"):
					if atte in (path+filename):
						poss.append(path+filename)

	if len(poss) > 0:
		print "\n -- Did you mean? -- "
		for i in poss:
			print i


def list_modules():
	print "Available modules"
	
	for root, dirnames, filenames in os.walk("modules"):
		for filename in filenames:
			path = root + "/"
			path = path.split("modules/")[1]
			if not "pyc" in filename and is_module("modules/"+path+filename):
				print "   " + path + filename

def is_module(path_to):
	fi = open(path_to, "rb")
	data = fi.read()
	fi.close()

	if "variables" in data and 'meta' in data and "class commands" in data and "info" in data and "author" in data and "ported_by" in data and 'version' in data:
		return True
	else:
		return False
	
def output_modules():
	modules = []
	for root, dirnames, filenames in os.walk("modules"):
		for filename in filenames:
			path = root + "/"
			path = path.split("modules/")[1]
			if is_module("modules/" + path + filename):
				modules.append(path + filename)
	return modules


def load_module(selection, prev):
	if os.path.isfile("modules/"+ selection) and "pyc" not in selection and ".." not in selection and is_module("modules/" + selection):
			print "Loading module.."
			return selection

	print "No module with that name."
	did_you_mean(selection)
	return prev

def isset(variable, module):
	for key in variables:
		if variable == key:
			return True
	if module == "TALOS":
		for key in vars_store:
			if variable == key:
				return True
	return False

def _get_var(variable, module):
	varout = None
	
	if variable in variables:
		varout = variables[variable]
	#if module == "TALOS":
	if variable in vars_store:
		varout = vars_store[variable]
	if varout is not None:
		return varout
	else:
		return ["","",""]


def length(variable):	
	if len(variable[0]) == 0 or variable[0] == "<variable_error>":
		return 0
	return len(variable[0].split(","))			

def pop_var(variablein, variableout, module):
	global qu
	value = None
	if variablein in variables:
		value = variables[variablein][0].split(", ")[0]
		variables[variablein][0] = ", ".join(variables[variablein][0].split(", ")[1:])
	elif variablein in vars_store:
		value = vars_store[variablein][0].split(", ")[0]
		vars_store[variablein][0] = ", ".join(vars_store[variablein][0].split(", ")[1:])
	#elif variablein in qu.variables:
	#	print "popping qu.var"
	#	value = qu.variables[variablein][0].split(", ")[0]
	#	qu.variables[variablein][0] = ", ".join(qu.variables[variablein][0].split(", ")[1:])
	else:
		value = qu.pop_var(variablein, None)

	if value is not None and variableout is not None:
		set_var(variableout, value, module)

	return value

def put_var(variable, value, module, required="no", description="Empty"):
	if module != "TALOS":
		for key in variables:
			if variable == key:
				if len(variables[variable]) == 3:
					if length(variables[variable]) > 0:
						variables[variable][0] += ", " + value
					else:
						variables[variable][0] = value
				else:
					variables[variable] = [value, required, description]
				return
	elif module == "TALOS":
		if variable in variables and len(variables[variable]) == 3:
                        if length(variables[variable]) > 0:
				variables[variable][0] += ", " + value
			else:
				variables[variable][0] = value
                else:
                        variables[variable] = [value, required, description]
                return

        if variable in vars_store and len(vars_store[variable]) == 3:
		if length(vars_store[variable]) > 0:
			vars_store[variable][0] += ", " + value

		else:
                	vars_store[variable][0] = value
        else:
                vars_store[variable] = [value, required, description]

        return

def del_var(variable):
	if variable in variables:
		del variables[variable]
	if variable in vars_store:
		del vars_store[variable]
	if variable in qu.variables:
		del qu.variables[variable]


def copy_var(variablein, variableout, module):
	value = None

	if variablein in variables:
		value = variables[variablein][0]
	elif variablein in vars_store:
		value = vars_store[variablein][0]
	elif variablein in qu.variables:
		value = qu.variables[variablein][0]

	if value is not None:
		set_var(variableout, value, module)
		

def set_var(variable, value, module, required="no", description="Empty"):
	if module != "TALOS":
		for key in variables:
			if variable == key:
				if len(variables[variable]) == 3:
					variables[variable][0] = value
				else:
					variables[variable] = [value, required, description]
				return
	elif module == "TALOS":
		if variable in variables and len(variables[variable]) == 3:
			variables[variable][0] = value
		else:
			variables[variable] = [value, required, description]
		return
	
	if variable in vars_store and len(vars_store[variable]) == 3:
		vars_store[variable][0] = value
	else:
		vars_store[variable] = [value, required, description]
	
	return
	

def more_variable(v):
	try:
		print v
		print "--------------------"
		print "Value: ", variables[v][0]
		print "Required: ", variables[v][1]
		print "Description: ", variables[v][2]
		print "--------------------"
	except:
		print "invalid variable name"
	return

def signal_handler(signal, frame):
	print "Exiting..."
	sys.exit(0)

def list_variables(varz=None):
	if varz is None:
		varz = variables
	TOO_LONG = False
	LONG_ERR = "too long, to view type 'more <variable>'"
	name = 5
	value = 6
	required = 9
	desc = 0

	if len(varz) == 0:
		print "Empty set"
		return

	for v in varz:
		if len(varz[v]) == 3:
			if len(v) > name:
				name = len(v)
			if len(varz[v][0]) > value:
				value = len(varz[v][0])
			if len(varz[v][2]) > desc:
				desc = len(varz[v][2])

	if desc > 50:
		TOO_LONG = True
		desc = len(LONG_ERR)
	total = 3 + name + value + required + desc

	print "Variables"
        sys.stdout.write("Name")
	for i in range(name - 3):
		sys.stdout.write(" ")
        sys.stdout.write("Value")
	for i in range(value - 4):
		sys.stdout.write(" ")
        sys.stdout.write("Required")
	sys.stdout.write("  ")
        sys.stdout.write("Description\n")
        for i in range(total):
		sys.stdout.write("-")
	print

	for variable in varz:
		if len(varz[variable]) == 3:
			sys.stdout.write(variable)
			for i in range(name - len(variable) + 1):
				sys.stdout.write(" ")
			sys.stdout.write(varz[variable][0])
			for i in range(value - len(varz[variable][0]) + 1):
				sys.stdout.write(" ")
			sys.stdout.write(varz[variable][1])
			for i in range(required - len(varz[variable][1]) + 1):
				sys.stdout.write(" ")
			if not len(varz[variable][2]) > 50:
				print varz[variable][2]
			else:
				print LONG_ERR
		elif len(varz[variable]) == 1:
			print variable, varz[variable]
		else:
			print "variable %s is corrupt" % (variable)
	for i in range(total):
		sys.stdout.write("-")
	print

def order_dictionary(temp):
	tamp = {}
	for key, value in sorted(temp.items()):
		tamp[key] = value
	return tamp

def mash_dictionaries(current):
	global variables
	global vars_store

	vars_store.update(variables)
	
	variables.update(vars_store)
	
	del_list = []
	temp = current.variables.copy()
	temp.update(variables)
	for key in temp:
		if key not in current.variables:
			del_list.append(key)
	for key in del_list:
		del temp[key]

	variables = order_dictionary(temp)

def list_commands(current):
	for command in dir(current.commands):
		if not "__" in command:
			print command
			if command == "run":
				print "run -j (run in background)"

def com_exec_picker(method, current, debug=True):
	if method == "launch":
		return com_exec_launch(method, current, debug)
	else:
		return com_exec(method, current, debug)

def com_exec_launch(method, current, debug=False):
	global qu


	to_e = getattr(current.commands, method)
	killme = threading.Event()
	pt = passthrough(qu, killme)
	if required_set(variables):
		qu.comrunning = True
		t = threading.Thread(target=to_e, args=(variables, pt, ))
		t.daemon=True
		t.start()
		threads.append([current.__file__,t, pt])
		
	else:
		return "required variables not set"

def com_exec(method, current, debug=True):
	global qu

	to_e = getattr(current.commands, method)
	killme = threading.Event()
	pt = passthrough(qu, killme)
	if required_set(variables):
		#qu.comrunning = True
		if debug:
			#print variables['tripcode'][0]
			return to_e(variables, pt)
		else:
			try:
				return to_e(variables, pt)
			except:
				print "Exiting module..."
				return None
	else:
		return "required variables not set"

def com_exec_background(method, current):

	to_e = getattr(current.commands, method)
	if required_set(variables):
		killme=threading.Event()
		pt = passthrough(qu, killme)
		p = threading.Thread(target=to_e, args=(variables, pt,))
		p.daemon = True
		p.start()
		threads.append([current.__file__,p,pt])
		return True
	else:
		return "required variables not set"	

def required_set(variables):
	for variable in variables:
		if variables[variable][1] == "yes":
			if len(variables[variable][0]) <= 0:
				return False
	return True

def kill_thread(num):
	threads[num][2].killme.set()


def list_jobs(current):
	count = 0
	#current.threads?
	removeplz = []
	print "Threads \n--------------------"
	try: 
		for thread in threads:
			status = str(thread[1]).split()[1].strip().lower()
			print count,"->", thread[0], "::", status
			if status=="stopped":
				removeplz.append(threads[count])
			count += 1
			
	except:
		print "no current threads"
	
	for item in removeplz:
		threads.remove(item)
	print 
	
	count = 0
	print "Processes \n--------------------"
	try:
		if len(processes) > 0:
			for process in processes:
				print count, "->", type(process)
				count += 1
		else:
			print "no current processes"
	except:
		print "no current processes"
	return

def help_module(module):
	try:
		help_me = imp.load_source("%s" % module,"modules/%s" % (module))
	except:
		return False
	
	
	try:
		minfo = help_me.meta['info']
	except:
		print "No help data for module"
		return True

	try:
		mauthor = help_me.meta['author']
		mported_by = help_me.meta['ported_by']
		mversion = help_me.meta['version']
	except:
		print "module is missing some meta elements"
		mauthor = "Blank"
		mversion = "Blank"
		mported_by = "Blank"

	print module
	print 'Author: ', mauthor
	print 'Ported by: ', mported_by
	print 'version: ', mversion
	print "-----------------------------------"
	print minfo
	print "-----------------------------------"
	return True

def help_command(command):
	help_texts = {
			'help':'Lists general help',
			'help <module>':'Help for module',
			'help <command>':'Help for command',
			'info':"Print info about Talos",
			'list modules':'List available modules',
			'list variables':'List current variables',
			'list commands':'List module specific commands',
			'list jobs':'List currently spawned threads and processes',
			'module':'Load a module by name',
			'set':'Set a variable to a value',
			'home':'Unload all modules',		
			'exit':'Exit TALOS',
			'read':'read a variable',
			'read notifications':'read unread notifications',
			'read old':'read all notifications in notify.log',
			'invoke <filename>':'invoke the script located at <filename>',
			'invoke <filename> <optional::argv1> <optional::argv2> etc..':'Invoke the script <filename> with as many arguments as are specified in the script.',
			'transcript':"Write your session history out to a file to be replayed as a script at a later date.",
			'transcript !justprint!':"Print your session history to the screen",
			'silence list':'List silenced modules',
			'silence add':'Silence a module (stop notifications)',
			'silence del':'Unsilence a module',			
			'silence':"Mute or unmute module notifications",

			'kill thread':"You can kill a thread by number.  If the module you're threading supports being killed in this way.  It might not.",
			'purge db':'Purges the Talos db',
			'purge db admin':'Purges the admin db',

			'purge log':"Purge the notifications log",
			'purge transcript':"Purge your session history"
			}

	if command in help_texts:
		print "--",str(command),"--"
		print ">",help_texts[command]
		return True
	print "No such module or command"
	return False

#I want a more powerful alias system to handle simple typos
#Also, autocomplete.. but that's different.
def alias(command):
	aliases = {
			'use':'module',
			'dir':'list variables',
			'ls':'list variables',
			'load':'module',
			'unload':'home',
			'show options':'list variables',
			'list options':'list variables',
			'show':'list',
			'quit':'exit',
			'run j':'run -j',
			':q':'exit',
			':q!':'exit',
			'q':'exit',
			'exit()':'exit',
			'q!':'exit',
			'exot':'exit'
		}
	aliases.update(additional_aliases)
	if command.strip() in aliases:
		return aliases[command.strip()]
	if len(command.split()) > 1:
		temp = []
		for word in command.split():
			if word in aliases:
				temp.append(aliases[word])
			else:
				temp.append(word)
		return " ".join(temp)
	return command

#I need to make this hierarchical
def complete(text, state):
	#options = [f for f in output_modules() if f.startswith(text)]
	com_buffer = readline.get_line_buffer()
	
	loaders = a_loaders
	coms = a_coms
	seconds = a_seconds
	
	loader = False
	first = False
	for com in coms:
		if com in com_buffer:
			first = True
	for l in loaders:
		if l in com_buffer:
			loader = True
	
	if first:
		options = [f for f in seconds if f.startswith(text)]
	elif loader:
		options = [f for f in output_modules() if f.startswith(text)]
	else:
		options = [f for f in coms if f.startswith(text)] + [f for f in loaders if f.startswith(text)]
	
	
	if state < len(options):
		return options[state]
	else:
		return None
def initialize():
	#Call global bootstrap functions
	init_a = bootstrap()

	#Init log file if not there.
	#Otherwise update it
	os.system("touch logs/notify.log")
	
	#Read in user defined aliases
	global additional_aliases

	fi = open("conf/aliases","r")
	data = fi.read()
	fi.close()

	for line in data.split("\n"):
		if len(line) > 0 and line[0] != "#":
			try:
				a = line.split(",")[0].strip()
				b = line.split(",")[1].strip()
				additional_aliases[a] = b
				
				global a_loaders
				global a_coms
				global a_seconds

				for i in range(2):
					if b in a_loaders:
						a_loaders.append(a)
					if b in a_coms:
						a_coms.append(a)
					if b in a_seconds:
						a_seconds.append(a)
					
					a = a + " "
					b = b + " "


			except:
				pass 
	return
	
def launch_bot(script):
	p = Process(target=_exec.call, args=("python ./talos.py --script scripts/%s" % (script),))
	p.daemon = True
	p.start()

def read_tripcode(tripcode):
	fi = open(mapping_finame,"r")
	data = fi.read()
	fi.close()

	temp = data.split("\n")
	for line in temp:
		if not "#" in line and "," in line and tripcode == line.split(",")[0]:
			launch_bot(line.split(",")[1])


def purge_db():
	esse = essential()
	esse.db_purge()
	time.sleep(1)
	esse.db_fill_tables()
	print "Database purged"

def purge_db_admin():
        dba = dbadmin()
        dba.db_purge()
	time.sleep(1)
	dba.db_fill_tables()
	print "Admin database purged"


def purge_transcript():
	global transcript
	transcript = []
	return

def purge_log(log):
	fi = open("logs/%s" % log,"w")
	fi.write("")
	fi.close()
	print "Log purged"
	return	

def load_log_unread(log):
	fi = open("logs/"+log,'r')
	data = fi.read()
	fi.close()

	temp = data.split("\n")
	data = []
	for line in temp:
		if len(line) > 0 and line[0] != "#":
			if "TRIPCODE:" in line and not "|||" in line:
				tripcode = line.split("TRIPCODE:")[1]
				mark_tripcode_read("notify.log",line)
				read_tripcode(tripcode)
			data.append(line)
	return data

def mark_log_read(log, line):
	line = line.replace("/","\/")
	os.system("sed -i 's/%s/#%s/' logs/%s" % (line, line, log))
	return

def mark_tripcode_read(log, line):
	line = line.replace("/","\/")
	os.system("sed -i 's/%s/%s|||/' logs/%s" % (line, line, log))
	return

def read_old():
	fi = open("logs/notify.log",'r')
	data = fi.read().split("\n")
	for line in data:
		print line

#add thread safe locking once everything is finalized
def read_notifications():
	global notifications

	temp = notifications
	notifications = []
	if len(temp) > 0:
		for line in temp:
			print line
			mark_log_read("notify.log",line)
	return

def log_notification(msg):
	fi = open("logs/notify.log", "a")
	fi.write(datetime.datetime.now()+":"+msg)
	fi.close()

#Thread safe locking once finalized
def mon_log(log):
	global notifications
	while True:
		bef = len(notifications)
		notifications = load_log_unread(log)
		if bef != len(notifications):
			if (len(notifications) - bef) != 1:
				s = "s"
			else:
				s = ""
			print "\nYou have received %s new notification%s" % (len(notifications) - bef, s)
			print "%s total unread notifications" % (len(notifications))
			sys.stdout.write( "command is: read notifications\n")
			#if not qu.comrunning:
			#	sys.stdout.write( "%s>>> %s" % (module, readline.get_line_buffer()) )
			sys.stdout.flush()		

		time.sleep(120)
			
	
def comparse(com, module, current):
	if not "`" in com:
		return com

	
	found = 0
	for char in com:
		if char == "`":
			found += 1
	if found != 2:
		return com
	
	com = com.split("`")
	
	try:
		parse_com(com[1], module, current)
	except Exception, e:
		if DEBUG:
			raise
		else:
			print "ERROR: [%s]" % e
		#	print "ERROR: Parse command.  To debug run talos.py with --debug switch."

	out = str(lastout)
	com = " ".join([com[0],out,com[2]])
	return com


def varparse(com):

	if not "$" in com and not "@" in com and not "%" in com:
		return com

	line = []

	for word in com.strip().lower().split():
		i = 1
		j = 0
		if len(word) > 3 and word[1] == "[" and word[3] == "]":
			i = 4
			j = int(word[2]) % 3
		if word[0] == "%":
			if word[i:] in vars_store:
				line.append(vars_store[word[i:]][j])
			else:
				line.append("<variable_error>")
		elif word[0] == "$":
			if word[i:] in variables:
				line.append(variables[word[i:]][j])
			else:
				line.append("<variable_error>")
		elif word[0] == "@":
			if word[i:] in qu.variables:
				line.append(qu.variables[word[i:]][j])
			else:
				line.append("<variable_error>")

		else:
			line.append(word)

	return " ".join(line)

def transcript_write(filename):
	if filename == "!justprint!":
		print "\n".join(transcript[:len(transcript)-1])
		return
	
	if os.path.exists(filename):
		print "This file already exists"
		print "Cannot write out transcript"
		return
	
	
	fi = open(filename, "w")
	fi.write("\n".join(transcript[:len(transcript)-1])+"\n")
	fi.close()
	print 'Transcript written out to file: %s' % filename
	return

def purposefail():
	raise Exception("Purposefail")

def silence_list():
	print "Tools Silenced"
	print "--------------"
	dba = dbadmin()
	a = dba.db_exec("select tool from silence", passthrough=True)
	for line in a:
		print line[0]

	
def silence_add(tool):
	dba = dbadmin()
	dba.db_exec("insert into silence (tool) values (\"%s\")" % tool)
	print "%s silenced" % tool

def silence_del(tool):
	dba = dbadmin()
	dba.db_exec("delete from silence where tool=\"%s\"" % tool)
	print "%s unsilenced" % tool


def info():
	for key in infostore.keys():
		if type(infostore[key]) == list:
			print key+":"+",".join(infostore[key])
		else:
			print key+":"+infostore[key]

def update():
	a,b = subprocess.Popen("git pull", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
	if not "Already up-to-date." in a:
		print a
		print
		print "TALOS updated"
		print "Please restart TALOS"
	else:
		print "Already up-to-date."

def cat(var0, var1):
	return str(var0) + str(var1)

def wait(sec):
	time.sleep(int(sec))
	return

def shell(com):
	try:
		_exec.call(com)
	except:
		print "some sort of shell error"
		print "this feature isn't fully integrated yet."

def eval_eq(com):
	return shlex.split(com.lower().strip())[1] == shlex.split(com.lower().strip())[3]

def eval_ne(com):
	return not eval_eq(com)

def eval_gt(com):
	return shlex.split(com.lower().strip())[1] > shlex.split(com.lower().strip())[3]

def eval_lt(com):
	return shlex.split(com.lower().strip())[1] < shlex.split(com.lower().strip())[3]

def conditionparse(com):
	global ifstate
	
	

	if ifstate is None and not "if" in com:
		return True
	
	if com.lower().strip() == "fi":
		ifstate = None
		return False

	if ifstate is not None and not ifstate:
		return False

	if com[0:2] == "if":
		if len(shlex.split(com)) == 4:
			if shlex.split(com.lower().strip())[2] == "==":
				ifstate = eval_eq(com)
				return False
			if shlex.split(com.lower().strip())[2] == "!=":
				ifstate = eval_ne(com)
				return False
			if shlex.split(com.lower().strip())[2] == ">":
				ifstate = eval_gt(com)
				return False
			if shlex.split(com.lower().strip())[2] == "<":
				ifstate = eval_lt(com)
				return False

	
	return True

def parse_com(com, module, current):
	global lastout
	if log_transcript:
		transcript.append(com)

	com = comparse(com, module, current)
	com = varparse(com)

	if not conditionparse(com):
		return module

	try:
		com[0] == "#"
	except:
		return module


	#not 100% sure this is where I want to put this
	#passes to launched module userHandler
	#We shall see
	if qu.comrunning and not com.strip().lower().split()[0] == "talos":
		try:
			handler = qu.handlers[qu.handler_count]
		except:
			print "Something went wrong"
			qu.comrunning = False
			return module
		if handler.writable():
			outval = handler.parse_com(com)
			if not outval:
				del qu.handlers[qu.handler_count]
				qu.handler_count -= 1
				qu.comrunning = False

			return module

	
	#DON'T ADD COMMANDS BEFORE THESE TWO
	#TALOS AND COMMENTS COME FIRST

	#talos
	#pass to high level interpreter from within module
	if com.strip().lower().split()[0] == "talos":
		com = " ".join(com.strip().lower().split()[1:])

	#comments
	if com[0] == "#":
		return module

	#info
	if com.strip().lower() == "info":
		info()
		return module	


	#silence
	if com.strip().lower() == "silence":
		print "silence (list/add/del)?"

	#silence list
	if com.strip().lower() == "silence list":
		silence_list()
		return module

	#silence add
        if " ".join(com.strip().lower().split()[0:2]) == "silence add":
		if len(com.strip().lower().split()) > 2:
                	silence_add(" ".join(com.strip().lower().split()[2:]))
		else:
			print "Add what?"
		return module

	#silence del
	if " ".join(com.strip().lower().split()[0:2]) == "silence del":
		if len(com.strip().lower().split()) > 2:
			silence_del(" ".join(com.strip().lower().split()[2:]))
		else:
			print "Del what?"
		return module

	#update
	if com.strip().lower() == "update":
		update()
		return module


	#purposefail
	if com.strip().lower() == 'pureposefail' or com.strip().lower() == "purposefail":
		pureposefail()
		return module

	#kill thread
	if com.strip().lower() == "kill thread":
		print "Kill which thread?"
		return module

	#kill thread <num>
	if " ".join(com.strip().lower().split()[0:2]) == "kill thread" and len(com.strip().lower().split()) == 3:

		try:
			lltnum = int(com.strip().lower().split()[2])
			print "Attempting to kill thread %s" % lltnum
			print "If it doesn't die it may not yet support being killed."
			print 
			kill_thread(lltnum)
		except:
			print "Something went wrong.  Did you enter a valid thread number?"
		return module


	#transcript without argument
	if com.strip().lower() == "transcript":
		print "Need to supply an output file"
		print "transcript <filename>"
		print "OR to just print"
		print "transcript !justprint!"
		return module

	#transcript
	if len(com.strip().lower().split()) == 2 and com.strip().lower().split()[0] == "transcript":
		transcript_write(com.strip().lower().split()[1])
		return module

	#del <var>
	if len(com.strip().lower().split()) == 2 and com.strip().lower().split()[0] == "del":
		del_var(com.strip().lower().split()[1])
		return module

	#copy
	if len(com.strip().lower().split()) == 3 and com.strip().lower().split()[0] == "copy":
		copy_var(com.strip().lower().split()[1], com.strip().lower().split()[2], module)
		return module

		
	#cat <var0> <var1>
	if len(shlex.split(com.strip().lower())) == 3 and shlex.split(com.strip().lower())[0] == "cat":
		lastout = cat(shlex.split(com.strip().lower())[1], shlex.split(com.strip().lower())[2])
		return module


	#inc
	if len(com.strip().lower().split()) == 2 and com.strip().lower().split()[0] == "inc":
		inc(com.strip().lower().split()[1])	
		return module

	#dec
        if len(com.strip().lower().split()) == 2 and com.strip().lower().split()[0] == "dec":
                dec(com.strip().lower().split()[1])
                return module


	#shell
	if len(shlex.split(com.strip())) > 1 and shlex.split(com.strip().lower())[0] == "shell":
		shell(shlex.split(com.strip())[1:])
		return module

	#goto
	if len(shlex.split(com.strip().lower())) == 2 and shlex.split(com.strip().lower())[0] == "goto":
		return shlex.split(com.strip().lower())[1] + "|||" + module

	#wait
	if len(com.strip().lower().split()) == 2 and com.strip().lower().split()[0] == "wait":
		try:
			wait(com.strip().lower().split()[1])
		except:
			pass
		return module

	#echo vars_store
	if com.strip().lower() == "echo::vars_store":
		print vars_store
		return module

	#echo variables global
	if com.strip().lower() == "echo::variables":
		print variables
		return module

	#echo
	if len(shlex.split(com.strip().lower())) == 2 and (shlex.split(com.strip().lower())[0] == "print" or shlex.split(com.strip().lower())[0] == "echo"):
		print shlex.split(com.strip().lower())[1]
		return module

	#help
	if com.strip().lower() == "help":
		print_help()
		return module
	
	#help module || help command
	if len(com.strip().lower().split()) > 1 and com.strip().lower().split()[0] == "help":
		if not help_module(com.strip().lower().split()[1]):
			help_command(str(" ".join(com.strip().lower().split()[1:])))
		return module

	#invoke
	if len(com.strip().lower().split()) >= 2 and com.strip().lower().split()[0] == "invoke":
		
		targv = None
		if len(com.strip().lower().split()) > 2:
			targv = com.strip().lower().split()[2:]

		module = read_loop(filename=com.strip().lower().split()[1], doreturn=True, argv=targv)
		return module

	#list
	if com.strip().lower() == "list":
		print "list what?"
		return module

	#list modules
	if com.strip().lower() == "list modules":
		list_modules()
		return module
	
	#list variables
	if com.strip().lower() == "list variables":
		list_variables()
		return module

	#list commands
	if com.strip().lower() == "list commands":
		if module == "TALOS":
			print "no module loaded"
			return module
		else:
			list_commands(current)
			return module

	#list jobs
	if com.strip().lower() == "list jobs":
		if module == "TALOS":
			return module
		else:
			list_jobs(current)
			return module

	#list inst_vars
	if com.strip().lower() == "list inst_vars":
		list_variables(qu.variables)
		return module

	#module
	if com.strip().lower() == "module":
		print "need to specify module"
		return module

	#module <module>
	if "module" in com.strip().lower() and len(com.strip().lower().split()) == 2:
		return load_module(com.strip().lower().split()[1], module)

	#put
	if len(com.strip().lower().split()) < 3 and com.strip().lower().split()[0] == "put":
		print "put what into what?"
		return module

	#put
	if len(shlex.split(com.strip().lower())) == 3 and shlex.split(com.strip().lower())[0] == "put":
		put_var(shlex.split(com.strip().lower())[1],shlex.split(com.strip().lower())[2], module )		
		return module

	#put <variable> <value> <required> 
	if len(shlex.split(com.strip().lower())) == 4 and shlex.split(com.strip().lower())[0] == "put":
                put_var(shlex.split(com.strip().lower())[1],shlex.split(com.strip().lower())[2], module, shlex.split(com.strip().lower())[3] )
                return module

	#put <variable> <value> <required> <description>
	if len(shlex.split(com.strip().lower())) > 4 and shlex.split(com.strip().lower())[0] == "put":
                put_var(shlex.split(com.strip().lower())[1],shlex.split(com.strip().lower())[2], module, shlex.split(com.strip().lower())[3], " ".join(shlex.split(com.lower().strip())[4:])  )
                return module

	#isset <variable>
	if len(com.strip().lower().split()) == 2 and com.strip().lower().split()[0] == "isset":
		lastout = isset(com.strip().lower().split()[1], module)
		print lastout
		return module

	#length <variable>
	if len(com.strip().lower().split()) == 2 and com.strip().lower().split()[0] == "length":
		lastout = length(_get_var(com.strip().lower().split()[1], module))
		print lastout
		return module

	#pop
	if com.strip().lower() == "pop":
		print "pop what?"
		return module

	#pop <variable>
	if len(com.strip().lower().split()) == 2 and com.strip().lower().split()[0] == "pop":
		lastout = pop_var(com.strip().lower().split()[1], None, module)
		return module


	#pop <variable> <output>
	if len(com.strip().lower().split()) == 3 and com.strip().lower().split()[0] == "pop":
		pop_var(shlex.split(com.strip().lower())[1], shlex.split(com.strip().lower())[2], module)
		return module


	#set
	if com.strip().lower() == "set":
		print "set what?"
		return module
	
	#set <variable> <value>
	if len(shlex.split(com.strip().lower())) == 3 and com.strip().lower().split()[0] == "set":
		set_var(shlex.split(com.strip().lower())[1],shlex.split(com.strip().lower())[2], module)
		return module
	
	#set <variable> <value> <required>
	if len(shlex.split(com.strip().lower())) == 4 and com.strip().lower().split()[0] == "set":
		set_var(shlex.split(com.strip().lower())[1],shlex.split(com.strip().lower())[2], module, shlex.split(com.strip().lower())[3])
		return module

	#set <variable> <value> <required> <description>
	if len(shlex.split(com.strip().lower())) > 4 and shlex.split(com.strip().lower())[0] == "set":
		set_var(com.strip().lower().split()[1],com.strip().lower().split()[2], module, com.strip().lower().split()[3], " ".join(com.strip().lower().split()[4:]))
		return module

	#home
	if com.strip().lower() == "home":
		return 'TALOS'

	#exit
	if com.strip().lower() == "exit":
		exit(0)

	
	#more <variable>
	if len(com.strip().lower().split()) == 2 and com.strip().lower().split()[0] == "more":
		more_variable(com.strip().split()[1])
		return module
	
	#read notifications
	if com.strip().lower() == "read notifications":
		read_notifications()
		return module
	
	#read old
	if com.strip().lower() == "read old":
		read_old()
		return module

	#purge db
	if com.strip().lower() == "purge db":
		purge_db()
		return module

	#purge db admin
	if com.strip().lower() == "purge db admin":
		purge_db_admin()
		return module

	#purge log
	if com.strip().lower() == "purge log":
		purge_log("notify.log")
		return module

	#purge transcript
	if com.strip().lower() == "purge transcript":
		purge_transcript()
		return module

	#query
	if len(com.strip().lower().split()) > 1 and com.strip().lower().split()[0] == "query":
		e = essential()
		e.db_exec(com.strip().lower().split()[1:])
		return module

	###parse commands
	if not isinstance(current, str):
		#print current.__file__
		if len(com.strip().lower().split()) < 2:
			if com.strip().lower() in dir(current.commands):
				temp = com_exec_picker(com.strip().lower(), current)
				
				
				if temp is not None and "|||" in temp:
					new_mod = temp.split("|||")[0]
					temp = temp.split("|||")[1]
					module = load_module(new_mod,module)
					if module != module_history[-1] and module != "TALOS":
						current = imp.load_source('%s' % module,'modules/%s' % (module))
						mash_dictionaries(current)


					com_exec_picker("run",current)
				
				#print temp
				return module
		elif len(com.strip().lower().split()) == 2 and com.strip().lower().split()[1] == "-j":
			if com.strip().lower().split()[0] in dir(current.commands):
				temp = com_exec_background(com.strip().lower().split()[0], current)
				#print temp
				return module
		elif len(com.strip().lower().split()) == 2 and com.strip().lower().split()[1] == '-d':
			print "Running in debug mode"
			if com.strip().lower().split()[0] in dir(current.commands):
				temp = com_exec_picker(com.strip().lower().split()[0], current, True)
				#print temp
				return module

	print "No such command"
	return module

def inc(var):
	if not var in variables.keys():
		return False
	try:
		variables[var][0] = str(int(variables[var][0])+1)
		return True
	except:
		return False


def dec(var):
	if not var in variables.keys():
		return False
	try:
		variables[var][0] = str(int(variables[var][0])-1)
		return True
	except:
		return False


def read_loop(filename="", doreturn=False, argv=None):
	global module
	global module_history
	global current
	global qu
	
	qu.comrunning = False

	if len(filename) > 0:
		data = ""
		try:
			fi = open(filename, "r")
			data = fi.read()
			fi.close()
		except:
			print "Found no script by that name"
			return module
		
		if argv != None and type(argv) == list:
			for i in xrange(len(argv)):
				varr = "$"+str(i+1)
				print "Replacement: ", str(argv[i])

				data = data.replace(varr, str(argv[i]))

		fi = open('/tmp/talosbuffer',"w")
		fi.write(data)
		fi.close()

		commands = data.split("\n")
		
		i = 0
		while i < len(commands):
			time.sleep(pausetime)
			command = commands[i]
			if module != module_history[-1]:
				module_history.append(module)
			try:
				module = parse_com(alias(str(command)),module,current)
			except Exception, e:
				if DEBUG:
					raise
				else:
					print "ERROR: [%s]" % e
					#print "ERROR: Parse command.  To debug run with --debug switch"

			#goto line in script
			if "|||" in module:
				global ifstate
				ifstate = None
				temp = module.split("|||")
				module = temp[1]
				for j in range(len(commands)):
					if temp[0] == commands[j]:
						i = j	


			if module != module_history[-1] and module != "TALOS":
				current = imp.load_source('%s' % module,'modules/%s' % (module))
				mash_dictionaries(current)

	
			i += 1

		if doreturn:
			return module
		
	
	
	while True:
		if module != module_history[-1]:
			module_history.append(module)
		if not qu.comrunning:
			prompt = module + ">>>"
		else:
			prompt = qu.get_prompt() 
		
		
		try:
			module = parse_com(alias(str(raw_input("%s " % (prompt)))), module, current)
		except Exception, e:
			if DEBUG:
				raise

			else:
				print "ERROR: [%s]" % e
				#print "ERROR: Parse command.  To debug run with --debug switch"
		
		if module != module_history[-1] and module != "TALOS":
			current = imp.load_source('%s' % module,'modules/%s' % (module))
			mash_dictionaries(current) 

if __name__ == "__main__":
	initialize()
	
	parser = argparse.ArgumentParser()
	parser.add_argument("-s","--script", help="A script file to run")
	parser.add_argument("--no-check",action="store_true", help="don't check for updates")

	parser.add_argument("-ta","--targv", help="Pointer to a CSV format file containing optional arguments for script")
	parser.add_argument("-nt","--no-transcript", action='store_true', help="Do not track the session transcript, for whatever reason")
	parser.add_argument("--debug", action='store_true', help='Enable debugging features (reduced error handling)')
	
	args = parser.parse_args()
	
	t = threading.Thread(target=mon_log, args=("notify.log",))
	t.daemon = True
	t.start()

	readline.parse_and_bind("tab: complete")
	readline.set_completer(complete)	
	readline.set_completer_delims(" ")

	module = 'TALOS'
	module_history = ["TALOS"]
	print_banner()
	
	if not args.no_check and not conf.no_check:
		check_updates()

	
	if args.debug or conf.debug:
		DEBUG = True

	if args.no_transcript or conf.no_transcript:
		log_transcript = False

	if conf.script:
		read_loop(conf.script)

	if args.script:
		targv=None
		if args.targv:
			targv=open(args.targv,"r").read().split(",")

		read_loop(args.script, argv=targv)
	else:
		while True:
			try:
				read_loop()
			except KeyboardInterrupt:
				print "Received Interrupt Signal"
				print "Would you like to exit?"
				rea = raw_input("[Y/n]>>> ")
				if rea.lower() == "y" or rea.lower()=="yes":
					print "Exiting.. "
					exit()
			

