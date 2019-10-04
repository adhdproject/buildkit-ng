#!/usr/bin/env python

import os
import subprocess

a = subprocess.Popen("netstat -antp | awk '/ESTABLISHED/ {print $7}'", shell=True, stdout=subprocess.PIPE)
out, err = a.communicate()

pids = []

for entry in out.split("\n"):
	if len(entry) > 1:
		print entry.split("/")[0]
		pids.append(entry.split("/")[0])


if len(pids) > 0:
	for pid in pids:
		if len(pid) > 0 and pid !="0":
			ppid = 11
			while int(ppid) > 10:
				print pid
				a = subprocess.Popen("ps -p %s -o ppid=" % (pid), shell=True, stdout=subprocess.PIPE)
				out, err = a.communicate()
				ppid = out.strip()
		
				a = subprocess.Popen("netstat -antp | awk '{split($7,a,\"/\"); if(a[1] == %s) {print $6}}'" % (ppid), shell=True, stdout=subprocess.PIPE)
				out, err = a.communicate()
				if "ESTABLISHED" in out:
					a = subprocess.Popen("ps -p %s -o comm=" % (ppid), shell=True, stdout=subprocess.PIPE)
					output, err = a.communicate()
					print "Alert: %s :: %s" % (ppid, output)
					ppid = 0
				else:
					pid = ppid
