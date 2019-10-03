import datetime
from core.database import dbadmin


def log_notification(msg, tool=None):
	if tool == None:
		tool = "Tool Unspecified"
	else:
		dba = dbadmin()
		try:
			if tool == dba.db_exec("select tool from silence where tool=\"%s\"" % (tool), passthrough=True)[0][0]:
				return
		except:
			pass
		


	fi = open("logs/notify.log","a")
	fi.write(str(datetime.datetime.now())+":"+str(tool) + ":" + str(msg)+"\n")
	fi.close()
	return

def log_tripcode(msg, tripcode, tool=None):
	if tool == None:
		tool = "Tool Unspecified"
	fi = open("logs/notify.log","a")
	fi.write(str(datetime.datetime.now())+":"+str(tool)+":"+str(msg)+"TRIPCODE:"+tripcode+"\n")
	fi.close()
	return
