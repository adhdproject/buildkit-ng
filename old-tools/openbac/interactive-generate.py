#!/usr/bin/env python
import os
import subprocess

class main():

	def __init__(self):
		self.init = True;
		self.options = {"single/file/local":[self._single_file_local,"Create the ball as a single local file."],
				"exit":[exit,"Leave script"]
				}

	def menu(self):
		print """
###########################
#Welcome to Ball and Chain#
######  generate.py  ######

		"""

		print "--- Options ---"			
		for i in self.options:
			print i, ":", self.options[i][1]
		print "Please type the name of the option you would like"
		
		choice = ""
		while choice not in self.options:	
			choice = raw_input(">>> ")
		self.options[choice][0]()	
		

	def tosize(self, num, suffix='B'):
		for unit in ['','Ki','Mi','Gi','Ti','Pi','Ei','Zi']:
		        if abs(num) < 1024.0:
        		    return "%3.1f%s%s" % (num, unit, suffix)
        		num /= 1024.0
    		return "%.1f%s%s" % (num, 'Yi', suffix)

	def _single_file_local(self):
		#enter
		print " "
		print "You need to decide on a byte length for the keys."
		print "This will inform the size of the ball."
		print "Enter a value for 2^x to see more about it."
		
		confirm = "n"
		bytenum = 0
		while confirm.lower() != "y" and confirm.lower() != "yes":
			bytenum = raw_input(">>>")
			try:
				bytenum = int(bytenum)
			except:
				bytenum = ""
			if isinstance( bytenum, (int , long)) and bytenum > 10 and bytenum < 46:
				print "key (bytes): %s, array: %s" % (bytenum, self.tosize(2**bytenum))
				confirm = raw_input("Good? [Y/n]:")
				
			elif bytenum == "exit":
				print "exiting..."
				exit()
			else:
				print "Please enter a number ( 46 > x > 10 ) or \"exit\""
			
		intval = 2**bytenum

		print " "
		print "Now we need a file to write to"
		filename = raw_input("filename>>> ")
		
		if(os.path.exists(filename)):
			print "This file already exists"
			print "Quitting..."
			exit()

		fi = open(filename, "a")
		
		while intval > 1:
			fi.write(os.urandom(1024))
			intval -= 1024
		fi.close()

		fi = open("openbac.conf","r")
		data = fi.read()
		fi.close()

		temp = []
		for line in data.split("\n"):
			if line[0:3] == "poi" and "pointerlengths: " in line:
				line = "pointerlengths: %s" % str(bytenum)
			if line[0:3] == "arr" and "arrayfile: " in line:
				line = "arrayfile: %s" % str(filename)

			temp.append(line)

		data = "\n".join(temp)

		fi = open("openbac.conf","w")
		fi.write(data)
		fi.close()

		print "Operation complete\n"
		print "--- Results ---"
		print "File: %s\nKeylen (bytes): %s\nFilelen %s" % (filename, bytenum, self.tosize(2**bytenum))




if __name__ == "__main__":
	m = main()
	m.menu()
	
