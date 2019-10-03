#!/usr/bin/env python
import signal

class sig:
	option = 4

	def __init__(self):
		import signal
		return

	
	def sigg(self, signal, frame):
		option = self.option
		if option == 1:
			sys.exit(0) #exit clean
		elif option == 2:
			sys.exit(1) #exit with error
		elif option == 3:
			return	    #return
		elif option == 4:
			print "catch"
