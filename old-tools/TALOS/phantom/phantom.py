#!/usr/bin/env python
import asyncore
import socket
import time
import errno
import imp
import ast
import subprocess
import select 
import sys
import Queue
import threading
import shlex
import traceback

from multiprocessing import Process
from twisted.internet import reactor
from twisted.internet.protocol import Protocol, Factory
from twisted.internet.endpoints import TCP4ClientEndpoint, connectProtocol
from twisted.internet.threads import deferToThread

class local_commands:
	def __init__(self):
		return


	#ls
	def _ls(self, folder):
		try:
			return subprocess.check_output(["ls",folder])
		except:
			return "Error processing command"

	def _touch(self, folder):
		try:
			return subprocess.check_output(['touch',folder])
		except:
			return "Error processing command"


class phantom(Protocol):
	temp_mod = 'module'	
	SIZE = 1024 #Socket read size

	processes = []
	threads = []
	q = Queue.Queue()
	mod_counter = 0

	def connectionMade(self):
		reactor.callFromThread(self.transport.write, "readyForCommand")

	def monQ(self):
		while True:
			time.sleep(5)
			if self.q.qsize() > 0:
				a = self.q.get()
				a = shlex.split(a.strip().lower())
				if a[0] == "tripcode":
					self.tripcode(" ".join(a[1:]))
				elif a[0] == "set":
					self.set_var(" ".join(a[1:]))
				
	def set_var(self, var=None):
		if var is not None:
			print "setting %s" % var
			reactor.callFromThread(self.transport.write, "set %s" % var)
		return True

	def tripcode(self, tripcode=None):
		#self.transport.write("tripcode %s" % tripcode)
		#reactor.callFromThread(self.transport.write, "tripcode %s" % tripcode)
		#print "tripcode function launched"
		if tripcode is not None:
            	#	print "MADE IT"
			reactor.callFromThread(self.transport.write, "tripcode %s" % tripcode)
        	#deferToThread(self.q.get).addCallback(self.tripcode)
		return True
	
	def echo(self, msg):
		print msg
		return

	#command methods
	def write_mod(self, data):
		#try:
		#	print 1
		print data
		fi = open(self.temp_mod, 'w')
		fi.write(data)
		fi.close()
		#self.module = imp.load_source("*",self.temp_mod)
		#self.module_loaded = True

		return "print module loaded"
		#except:
		#	return False

	def launch_mod(self, data):
		#remember to use the 'DELIM' markers
		data = data.split("DELIM")[1]
		print data
		current = imp.load_source("phantom::"+str(self.mod_counter),self.temp_mod)
		self.mod_counter += 1
		current.commands.run(ast.literal_eval(data.strip()), self.q)
		return "print module launched in foreground"	

	def launch_background(self, data):
		
		data = data.split("DELIM")[1]
		print data
		current = imp.load_source("phantom::"+str(self.mod_counter),self.temp_mod)
		self.mod_counter += 1
		#self.tripcode()
		#current.session = self
		p = threading.Thread(target=self.monQ,args=())
		p.daemon=True
		p.start()
		inst = current.commands
		P = threading.Thread(target=inst.run, args=(ast.literal_eval(data.strip()),self.q) )
		P.daemon = True
		P.start()
		self.threads.append(P)
		self.threads.append(p)
		return "print module backgrounded"

	def parse_com(self, data):
		print data
		ll = local_commands()

		#push
		if len(data.split()) > 1 and data.split()[0] == "push":
			return self.write_mod(data[5:])
		
		#background
		#if len(data.split()) > 1 and data.split()[0] == "background":
	#		return self.launch_background(data)
		
		#launch
		if len(data.split()) > 1 and data.split()[0] == "launch":
			return self.launch_background(data)

		#ls
		if len(data.split()) == 2 and data.split()[0] == "ls":
			return "print "+ ll._ls(data.split()[1])

		#touch
		if len(data.split()) == 2 and data.split()[0] == "touch":
			return "print "+ ll._touch(data.split()[1])

		#printed
		if len(data.split()) == 1 and data.split()[0] == "Printed":
			return None		
	
		#exit
		if len(data.split()) == 1 and data.split()[0] == "exit":
			reactor.stop()

		if "Exception" in data:
			return None

		print "NoCommandFoundException"
		return None



	def loseConnection(self):
		exit()

	def dataReceived(self, data):
		try:
			out = self.parse_com(data)
		except Exception, e:
			print "Unexpected error:", sys.exc_info()[0]
			print e
			out = "print phantom exception %s" % e
			traceback.print_exc(file=open("/tmp/errlog.txt","a"))
			
		if out is not None:
			reactor.callFromThread(self.transport.write, out)
			return
		else:
			reactor.callFromThread(self.transport.write, "readyForCommand")
			return

p = TCP4ClientEndpoint(reactor, "localhost", 1226)
d = connectProtocol(p, phantom())

reactor.run()
