"""Sweeper is a honeyports esque program.  It searches specifically for sweeping scans or repeated connections rather than just arbitrary connections to a single port.  It can block and/or alert once a scan is detected."""


import asyncore
import socket
import sys
import os
import smtplib

if len(sys.argv) < 2:
	print "Improper Usage"
	print "More like this..."
	print sys.argv[0] + " <port1> <port2> <port3>"

l = []
threshold = 2

#To enable actions, uncomment them and customize variables
def action(addr):
	print "Actions taken against " + addr
	
	print "IP Blocked via Iptables"
	os.system("iptables -I INPUT -s " + addr + " -j DROP")

	#print "Alert emailed"
	#fromaddr = "me@gmail.com"
	#toaddr = "me@gmail.com"
	#msg = "Sweeper.py alert for IP " + addr
	#username = fromaddr
	#password = "mypassword"
	#server = smtplib.SMTP('smtp.gmail.com:587')
	#server.ehlo()
	#server.starttls()
	#server.login(username,password)
	#server.sendmail(fromaddr,toaddr,msg)
	#server.quit()
	
class sweeper_handler(asyncore.dispatcher_with_send):
		def handle_read(self):
			self.send("Password: ")
			data = self.recv(1024)

class listening_socket(asyncore.dispatcher):
	def __init__(self,host,port):
		self.port = port
		self.host = host
		asyncore.dispatcher.__init__(self)
		self.create_socket(socket.AF_INET,socket.SOCK_STREAM)
		self.set_reuse_addr()
		self.bind((host,port))
		self.listen(5)

	def handle_accept(self):
		acc = self.accept()
		if acc is not None:
			sock, addr = acc
			self.mustache(addr[0])
			print "Connection %s->%s" % (repr(addr), self.port)
			handler = sweeper_handler(sock)

	def mustache(self,addr):
		temp = None
		for i in range(len(l)):
			if l[i][0] == addr:
				temp = i
				break

		if temp is not None:
			if l[temp][1] < threshold:
				l[temp][1] = l[temp][1] + 1
			else:
				action(addr)
		else:
			l.append([addr,1])
		

for i in range(len(sys.argv)-1):
	listening_socket("",int(sys.argv[i+1]))
asyncore.loop()
