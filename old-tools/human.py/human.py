#!/usr/bin/env python

"""
Human.py V0.5
Detects humans using service accounts.
For when a service account pass is compromised
Currently only supports linux.
"""

import sys
import os
import subprocess
import time
import smtplib
import syslog

debug = False

#FOR EMAIL ALERTS
#Edit these to enable
email_user = ""
email_pass = ""

to_addr = ""

email_host = ""
email_port = 587
email_tls = False

#Set to true to disable logging to stdout
silent = False

#This is a unique system id to use in the email alerts
#Leave blank unless your email has multiple reports coming in.
system_id = ""


#logfile
#Where to log alerts and errors.
alert_log = "custom.log"

#Kind of important that you keep a good lock on the logfile.  It's gonna contain sensitive information for whatever user account you're targeting.
signatures = ["command not found","No command","did you mean","No such file or directory","Not a directory"]

if os.getuid() != 0:
        print "Please only run as root"
        print "I want good privilege seperation with these log files"
        exit(0)

if len(sys.argv) < 2:
	print "Human identification on service accounts"
	print "Proper Usage"
	print sys.argv[0] + " <username_to_monitor> "
	print "or"
	print sys.argv[0] + " <username_to_stop_monitoring> stop "
	exit(1)

user = sys.argv[1]

baselogpath = "/var/log/human/"
logfile = "%s%s" % (baselogpath, user)

def user_exists(user):
	fi = open("/etc/passwd","r")
	passwddata = fi.read()
	fi.close()

	for line in passwddata.split("\n"):
		if user in line.split(":")[0]:
			return True

	return False

def is_email_enabled():
	return len (email_host) > 0 and len(email_user) > 0 and len(email_pass) > 0 and len(to_addr) > 0

def _log(msg):
	if is_email_enabled():
		if debug:
			email_alert( msg + "::" +  str(system_id) )
		else:
			try:
				email_alert( msg + "::" +  str(system_id) )
			except:
				write_alert("Email failed to send")


	if not silent:
		print msg
	
	if syslog:
		syslog.syslog("%s" % msg)

	if len(alert_log) > 0:
		write_alert("%s" % msg)

def write_alert(msg):
	fi = open(alert_log, "a")
	fi.write("%s:%s\n" % ( time.strftime("%b %d %Y %H:%M:%S", time.gmtime(time.time())), msg))
	fi.close()

def email_alert(msg):
	server = smtplib.SMTP(email_host + ':' + str(email_port))
        if email_tls:
		server.starttls()
        server.login(email_user,email_pass)
        server.sendmail(email_user, to_addr, msg)
        server.quit()


def __build__():
	if not os.path.exists(baselogpath): 
		os.system("mkdir -p %s" % (baselogpath))
		os.system("chmod 711 %s" % (baselogpath))

def __exec__(com):
	p = subprocess.Popen(com, stdout=subprocess.PIPE, shell=True)
	out, err = p.communicate()
	return out

def gethome(user):
	home =  __exec__("awk 'BEGIN { FS=\":\" } ; /%s/ {print $6}' /etc/passwd" % (user))
	if home[-1] == "\n":
		home = home[:-1]
	if home[-1] != "/":
		home = home + "/"
	return home

def ismon(user):
	home = gethome(user)
	read = ""

	try:
		read = __exec__("grep 'exec 2> >(tee -a' %s.bashrc" % (home))
	except:
		print "No bashrc found, moving on."
		return False

	if len(read) < 3:
		return False
	else:
		return True

def start_mon(user):
	home = gethome(user)
	__exec__("touch %s " % (logfile))
	__exec__("mkdir -p %s && touch %s.bashrc" % (home, home))
	fi = open("%s.bashrc" % (home), "a")
	fi.write("exec 2> >(tee -a %s)" % (logfile))
	fi.close()
	__exec__("chmod 600 %s" % (logfile))
	__exec__("chown %s:%s %s" % (user, user, logfile))

def stop_mon(user):
	home = gethome(user)
	
	__exec__("sed -i '/exec 2\>/c\ ' %s.bashrc" % (home))
	__exec__("rm %s" % logfile)
	_log("Stopped monitoring user %s" % user)
	

def monitor_user(user):
	while True:
		out = __exec__("cat %s" % (logfile))
		for signature in signatures:
			if signature in out:
				_log("Alert <%s> is acting like a human" % (user))
				__exec__("> %s" % (logfile))
		time.sleep(10)

if __name__ == "__main__":
	if len(sys.argv) == 2 or (len(sys.argv) > 2 and sys.argv[2] != "stop"):
		print "-- starting mon service --"
	
		if is_email_enabled():
			print "Email alerts enabled"
		else:
			print "No email service linked"
			print "Edit %s to enable" % sys.argv[0]
	__build__()
	if not user_exists(user):
		print
		_log( "!!!User %s doesn't exist!!!" % user )
		sys.exit(-1)
	if not ismon(user):
		start_mon(user)
	if len(sys.argv) > 2 and sys.argv[2]  == "stop":
		stop_mon(user)
		exit(0)

	monitor_user(user)


	
