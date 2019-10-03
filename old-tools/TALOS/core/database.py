#!/usr/bin/env python
import sqlite3
from subprocess import Popen as popen


class dbadmin:
	db_file = 'assets/admin.db'

	schema = [
		"silence (id INTEGER primary key autoincrement, tool TEXT)",
		"talos (id INTEGER primary key autoincrement)"
		]

	def __init__(self):
		try:
                        conn = sqlite3.connect(self.db_file)
                        c = conn.cursor()
                        c.execute("select * from talos")
                        conn.close()
		except:
			self.db_fill_tables()

		return

	def db_purge(self):
		popen("rm %s -f && touch %s" % (self.db_file, self.db_file), shell=True)


	def db_fill_tables(self):
		for line in self.schema:
			self.db_create_table(line)

	def db_create_table(self, table):
                conn = sqlite3.connect(self.db_file)
                c = conn.cursor()
                c.execute("CREATE TABLE IF NOT EXISTS %s" % (table))
                conn.commit()
                conn.close()
                return

        def db_exec(self, commands, passthrough=False):
                conn = sqlite3.connect(self.db_file)
                c = conn.cursor()
                if type(commands) == list:
                        c.execute(" ".join(commands))
                elif type(commands) == str:
                        c.execute(commands)
                else:
                        print "type error"
		
		allr = c.fetchall()
	
		conn.commit()
		conn.close()

		if not passthrough:
			for line in allr:
				print line
		else:
			return allr
                return



class essential:
	#don't chance this just yet.  We're gonna work with a centralized database until I see a compelling need for multiple workstations.
	db_file = 'assets/talos.db'

	schema = [
		"requests (id TEXT, type TEXT, ip_address TEXT, user_agent TEXT, time INTEGER)",
		"invisiports_blacklist (ip text, date text)",
		"talos (id INTEGER primary key autoincrement)"
		]

	def __init__(self):
		try:
			conn = sqlite3.connect(self.db_file)
			c = conn.cursor()
			c.execute("select * from talos")
			conn.close()
		except:
			self.db_fill_tables()

	def db_purge(self):
                popen("rm %s -f" % self.db_file, shell=True)


	def db_fill_tables(self):
		for line in self.schema:
			self.db_create_table(line)



	def db_create_table(self, table):
		conn = sqlite3.connect(self.db_file)
		c = conn.cursor()
		c.execute("CREATE TABLE IF NOT EXISTS %s" % (table))
		conn.commit()
		conn.close()
		return

	def db_exec(self, commands, passthrough=False):
		conn = sqlite3.connect(self.db_file)
		c = conn.cursor()
		if type(commands) == list:
			c.execute(" ".join(commands))
		elif type(commands) == str:
			c.execute(commands)
		else:
			print "type error"
		allr = c.fetchall()
		
		conn.commit()
		conn.close()
		

		if not passthrough:
			for line in allr:
				print line
		else:
			return allr
	
		return
