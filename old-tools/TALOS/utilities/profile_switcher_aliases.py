#!/usr/bin/env python
import subprocess
import datetime
import os

datetime_a = datetime.datetime.now().strftime("%Y-%m-%d__%H-%M")

def archive():
	subprocess.check_output("mkdir -p archive/conf/aliases", shell=True)
	subprocess.check_output("cp conf/aliases archive/conf/aliases/%s" % (datetime_a), shell=True)

def replace(prof):
	subprocess.check_output("cp -f conf/aliases/aliases.d/%s conf/aliases" % (prof), shell=True)
	return

def append(prof):
	subprocess.check_output("cat conf/aliases.d/%s >> conf/aliases" % (prof), shell=True)
	return

if not os.path.isfile("./talos.py"):
	print "You need to run this script from main talos directory"
	print "That is the folder that contains talos.py"
	exit(-1)

print 
print
print
print "      <<<<<<<<<< TALOS UTILITIES >>>>>>>>>>"
print "           -- profile_switer_aliases -- "
print " =============================================== "
print "This utility helps manage multiple alias profiles"
print "Alias profiles should be stored in conf/aliases.d"
print "All alias profiles must end with .ap"
print "All profiles must be formatted like conf/aliases"
print "This tool helps you alter conf/aliases"
print "You can replace or append conf/aliases"
choice = "n"
choices = ("r","a","replace","append")
while choice.lower() not in choices:
	choice = raw_input("replace/append [r/a]>> ") or n

profiles = subprocess.check_output("ls conf/aliases.d | grep '\.ap'", shell=True).split()

prof = None
while prof == None:
	print profiles
	prof = raw_input("Select a profile>> ") or None
	if prof not in profiles:
		prof = None


backup = None
while backup == None:
	backup = raw_input("Archive current aliases file? [y/n]>> ") or None
	if backup.lower() not in ("y","n","yes","no"):
		backup = None

if backup.lower() in ("yes","y"):
	archive()

if choice[0] == "r":
	replace(prof)
else:
	append(prof)

