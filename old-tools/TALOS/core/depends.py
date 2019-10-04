#!/usr/bin/env python

import pip
from sys import argv
from subprocess import check_output, Popen, PIPE
from os import devnull, execv

def ppip():
	installed = []
	installed = []
        fi = open("./REQUIREMENTS.txt", "r")
        data = fi.read()
        fi.close()

        tt= []

        output = check_output("pip freeze 2>/dev/null", shell=True).split("\n")
        for line in output:
                if len(line) != 0:
                        tt.append(line.split("==")[0].lower())

	printed = False
        for line in data.split("\n"):
                if len(line) != 0 and line not in tt:
                        if not printed:
                                printed = True

                        pip.main(["install","%s" % line])
                        installed.append("%s" % line)


        return (printed, installed)


def main():
	installed = []
	fi = open("./REQUIREMENTS.txt", "r")
	data = fi.read()
	fi.close()

	tt= []

	output = check_output("pip freeze 2>/dev/null", shell=True).split("\n")
	for line in output:
		if len(line) != 0:
			tt.append(line.split("==")[0].lower())



	printed = False
	for line in data.split("\n"):
		if len(line) != 0 and line not in tt:
			if not printed:
				printed = True

			with open(devnull, "w") as dvnull:
				a = Popen(["/usr/bin/pip","install","%s" % line], stdout=dvnull, stderr=dvnull)
				installed.append("%s" % line)


	return (printed, installed)
