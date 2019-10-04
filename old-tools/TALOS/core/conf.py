#!/usr/bin/env python

class conf:	
	def __init__(self, incoming):
		for key in incoming.keys():
			if incoming[key] is None:
				continue
			if incoming[key].lower() == "true":
				incoming[key] = True
			elif incoming[key].lower() == "false":
				incoming[key] = False

			setattr(self, key, incoming[key])


class buildconf:

	

	confdict = {
		"no_check":None,
		"script":None,
		"no_transcript":None,
		"debug":None
		}

	confphile = "conf/talos.conf"

	
	def __init__(self):

		data = ""
		with open(self.confphile, "r") as fi:
			data = fi.read()

		for line in data.split("\n"):
			if len(line) == 0 or line[0] == "#":
				continue
			line = line.replace("-","_")
			try:
				key, val = line.split(":")
				val = val.strip()
			except:
				continue
	
			if key in self.confdict.keys():
				self.confdict[key] = str(val)

