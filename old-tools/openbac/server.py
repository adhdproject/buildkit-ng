#!/usr/bin/env python

import socket
import ssl
import os

from urlparse import parse_qs

import subprocess
import argparse
import BaseHTTPServer, SimpleHTTPServer

import openbac


HOST = ""
PORT = 2337

CONFIGFILE = "openbac.conf"

m = ''

whitelist = []

class openbac_server:
	config = {}

	required_items = ["certfile","keyfile"]

	def __init__(self, args):
		global m
		m = self
		self.configfile = CONFIGFILE
		

		if not args.no_platform:
			self.check_platform()

		#try:
		self._parse_conf()
		#except:
		#	print "An error has occured while attempting to parse the configuration file %s " % self.configfile
		#	exit()

		parsr_output = self._check_conf()
		if len(parsr_output) > 0:
			print "We are having trouble parsing these items in the configuration file"
			count = 0
			for item in parsr_output:
				count += 1
				print "[%s]:" % count, item
				
			print "Please attempt to fix them and restart this program"
			exit()

		
		if not os.path.exists(self.config["certfile"]) or not os.path.exists(self.config["keyfile"]):
			if not args.no_cert_gen:
				subprocess.check_output('rm -f %s %s' % (self.config["keyfile"], self.config["certfile"]) , shell=True)
				self._gen_cert()
			else:
				print "This server needs a certificate to run"
				print "Exiting..."
				exit()
			
		print "\n\n#################\nListening..."
		self._serve()

	def check_platform(self):
		if os.name != "posix":
			print "This server currently only supports Linux"
			print "If you really want to try running on windows you can disable this check with --no-platform"
			exit()


	def _parse_conf(self):
		fi = open(self.configfile, "r")
		data = fi.read()
		fi.close()
		for line in data.split("\n"):
			if len(line) < 1 or line[0] == "#":
				continue
			line = line.split(":")
			if len(line) < 2:
				continue
			self.config[line[0].strip()] = line[1].strip()

		if "server_port" in self.config.keys() and self.config['server_port'] != "default":
			global PORT
			PORT = self.config["server_port"]

		if "server_addr" in self.config.keys() and self.config['server_addr'] != "default":
			global HOST
			HOST = self.config["server_addr"]

		if type(eval(self.config['pointerlengths'])) != list:
			temp = self.config['pointerlengths']
			self.config['pointerlengths'] = []
			for i in xrange(int(self.config['pointernum'])):
				self.config['pointerlengths'].append(temp)
		else:
			self.config['pointerlengths'] = eval(self.config['pointerlengths'])
		temp = self.config['whitelist']
		self.config['whitelist'] = []
		for i in temp.split(","):
			self.config['whitelist'].append(i)
		
		global whitelist
		whitelist += self.config['whitelist']

		if not os.path.exists(self.config['arrayfile']):
			print "It appears that you have not created an arrayfile yet."
			print "You can use interactive-generate.py to do this."
			print "WARNING: make sure your pointerlengths and number of pointers is set correctly in openbac.conf after generation."
			print "If you don't authentication will not work."
			print "\nExiting..."
			exit()

	def _check_conf(self):
		temp = []
		for item in self.required_items:
			if item not in self.config.keys():
				temp.append(item)

		return temp

	def _gen_cert(self):
		print "##################################"
		print "We need to generate a new ssl cert"
		print "##################################"
		print "\n\n"
		output = subprocess.check_output('openssl req -x509 -newkey rsa:4096 -keyout %s -out %s -days 2000 -nodes' % (self.config["keyfile"], self.config["certfile"]), shell=True)
		#Should check for command completion here
		#Make sure openssl is installed that is.
		return



	def _serve(self):
		try:
			serv = BaseHTTPServer.HTTPServer((HOST,PORT),Handler)
			serv.socket = ssl.wrap_socket(serv.socket, certfile=self.config["certfile"], keyfile=self.config['keyfile'] ,server_side=True)
			serv.serve_forever()
		except KeyboardInterrupt:
			print 'SIGINT received, shutting down server'
			serv.socket.close()

	def process(self, au):
		a = openbac.auth(self.config['pointerlengths'],filename=self.config['arrayfile'])
		return a.authenticate(au['au'])

	def gen(self, mk):
		a = openbac.auth(self.config['pointerlengths'],filename=self.config['arrayfile'])
		return a.generate(mk['mk'])

	def unpack(self, up):
		passwd = up['passwd']
		up = up['up']
		
		a = openbac.auth(self.config['pointerlengths'],filename=self.config['arrayfile'])
		return a.authenticate(a.unpack(passwd, up))
		

	def parse(self, path):
		parsed = parse_qs(path[2:])
		if "au" in parsed.keys():
			for i in parsed:
				parsed[i] = " ".join(parsed[i])
			print parsed
			return self.process(parsed)
		if "mk" in parsed.keys():
			for i in parsed:
				parsed[i] = " ".join(parsed[i])
			print parsed
			return self.gen(parsed)
		if "up" in parsed.keys() and "passwd" in parsed.keys():
			for i in parsed:
				parsed[i] = " ".join(parsed[i])
			print parsed
			return self.unpack(parsed)
		return "Not able to parse input"

class Handler(BaseHTTPServer.BaseHTTPRequestHandler):
	
	def do_GET(self):
		
		if(self.client_address[0]) not in whitelist:
			self.send_error(401, "No Access")

		r = m.parse(self.path)
		try:
			resp = m.parse(self.path)
			self.send_response(200)
			self.send_header('Content-type','text/html')
			self.end_headers()
			self.wfile.write(resp)
		except:
			self.send_error(500, "Something went wrong")


if __name__ == "__main__":
	parser = argparse.ArgumentParser(description='OpenBAC server, network authentication daemon')
	parser.add_argument('--no-platform', action='store_true', help='disable platform checks')
	parser.add_argument('--no-cert-gen', action='store_true', help='Disable automatic certificate generation')
	args = parser.parse_args()
	
	
	m = openbac_server(args)
