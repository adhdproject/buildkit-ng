#!/usr/bin/env python

import sys
from core.backbone import _exec
from multiprocessing import Process
import time

banner = """
	### TALOS AUTOMATION ###
	##   Choose a script  ##
	###                  ###
"""

while True:
	out = _exec.check_output("ls scripts/talos")

	scripts = []


	for script in out.split("\n"):
		if script == "." or script == ".." or len(script) == 0:
			continue
		print str(len(scripts)) + ") " + script
		scripts.append(script)

	print "Type Exit to exit"

	choice = raw_input(">>> ")
	if choice == "exit" or choice == "quit":
		sys.exit(0)

	if int(choice) < 0 or int(choice) > len(scripts) -1:
		continue 

	try:
		_exec.call("python ./talos.py --script scripts/talos/%s" % (scripts[int(choice)]), True)
	except:
		print "<><>"

	time.sleep(0.1)
	choice = raw_input("Exit or Launch New? [e/n]: ")
	if choice.lower() != "n":
		sys.exit(0)
