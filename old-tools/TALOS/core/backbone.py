import os
import subprocess
import shlex
import sys
import ast
import socket
import threading

from twisted.internet import reactor
from netaddr import *

class QU:
	
	def __init__(self):
		self.variables = {}
		self.handlers = {}
		self.handler_count = 0
		self.prompt = "#"
		self.prompt_addition = ""
		self.prompt_start = ""
		self.reactor = reactor
		self.comrunning = False
		self.listeners = []
		self.start_reactor()


	def start_reactor(self):
		t = threading.Thread(target=self.reactor.run, args=(False,))
		t.daemon = True
		t.start()

	def accept_input(self, handler):
		self.handler_count += 1
		self.handlers[self.handler_count] = handler
	
	def close_input(self, handler=None):
		if handler is None:
			del self.handlers[self.handler_count]
		else:
			for key in self.handlers:
				if self.handlers[key] == handler:
					del self.handlers[key]
		self.handler_count -= 1
		self.set_prompt("")
		self.comrunning = False
		return
	
	def length(self, variable):
		return len(variable[0].split(", "))

	def get_prompt(self):
		return self.prompt_start + self.prompt_addition + self.prompt

	def set_prompt(self, prompt_addition):
		self.prompt = str(prompt_addition)


	def put_var(self, variable, value, required="no", description="Empty"):
		if variable in self.variables:
			if self.length(self.variables[variable]) > 0:
				self.variables[variable][0] += ", " + str(value)
			else:
				self.variables[variable][0] = str(value)
		else:
			self.variables[variable] = [str(value),required,description]
		return

	def pop_var(self, variablein, variableout, globallevel=False):
		print "made it to qu.pop_var"
		value = None
		if variablein in self.variables:
			value = self.variables[variablein][0].split(", ")[0]
			self.variables[variablein][0] = ", ".join(self.variables[variablein][0].split(", ")[1:])
		if value is not None and variableout is not None:
			self.set_var(variableout, value)

		return value

	def set_var(self, variable, value, required="no", description="Empty"):
		if variable in self.variables:
			self.variables[variable][0] = str(value)
		else:
			self.variables[variable] = [str(value),required,description]
		return

def is_ip(ip):
	try:
		socket.inet_aton(ip)
	except:
		return False
	return True

def rhosts_process(data):
	i = IPSet()
	data = data.split(",")
	for entry in data:
		if "/" in entry:
			i.add(entry)
		if "--" in entry:
			start = entry.split("--")[0]
			end = entry.split("--")[1]
			i.add(IPRange(start, end))
		if "-" in entry:
			start = entry.split('-')[0]
			end = entry.split('-')[1]
			i.add(IPRange(start, end))
		if is_ip(entry):
			i.add(entry)	

	temp = []
	for ip in i:
		temp.append(ip)
	return temp

class _exec:

	def __init__(self):
		return


	#support
	@staticmethod
	def split_pipe(com, search="|"): #make sure you're passing a string
		try:
			out = com.split(search)
			return out
		except:
			return None

	#cleaning methods start
	@staticmethod
	def clean_in(com):
		if type(com) is str:
			com = shlex.split(com)
		if type(com) is not str and type(com) is not list:
			return None
		return com


	#command methods start
	@staticmethod
	def call(com, passme=False):
		com = _exec.clean_in(com)
		if com is None:
			return False
		if not passme:
			subprocess.call(com)
		else:
			FNULL = open(os.devnull, "w")
			subprocess.call(com, stdin=subprocess.PIPE, stderr=FNULL)
		return True

	@staticmethod
	def check_output(com):
		com = _exec.clean_in(com)
		if com is None:
			return None
		
		return subprocess.check_output(com)
		

	@staticmethod
	def pipeline(coms):
		last = None

		coms = _exec.split_pipe(coms)
		
		for com in coms:
			com = _exec.clean_in(com)
			if last is None:
				last = subprocess.Popen(com, stdout=subprocess.PIPE)
			else:
				last = subprocess.Popen(com, stdin=last.stdout, stdout=subprocess.PIPE)
		out, err = last.communicate()			
		return out, err	


	@staticmethod
        def pipegen(coms, gen=True):
                last = None

                coms = _exec.split_pipe(coms)

                for com in coms:
                        com = _exec.clean_in(com)
                        if last is None:
                                last = subprocess.Popen(com, stdout=subprocess.PIPE)
                        else:
                                last = subprocess.Popen(com, stdin=last.stdout, stdout=subprocess.PIPE)
                if gen:
                        while True:
                                line = last.stdout.readline()
                                if not line: break
                                yield line


