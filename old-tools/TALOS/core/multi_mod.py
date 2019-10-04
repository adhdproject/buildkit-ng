import imp

from multiprocessing import Process

class launcher:
	
	current = ""
	processes = []

	def __init__(self):
		return

	def launch(self, module, variables, qv, method="run", debug=True):
		
		self.current = imp.load_source('*','modules/%s' % (module))
		to_e = getattr(self.current.commands, method)
		if self.required_set(variables):
			if debug:
				return to_e(variables, qv)
				
			else:
				try:
					return to_e(variables, qv)
				except:
					print "Exiting module..."
					return None
		else:
			return "required variables not set"

	def launch_background(self, module, variables, qv,  method="run"):
		self.current = imp.load_source('*','modules/%s' % (module))
		to_e = getattr(self.current.commands, method)
		if self.required_set(variables):
			p = Process(target=to_e, args=(variables, qv))
			p.daemon = True
			p.start()
			self.processes.append(p)
			return True
		else:
			return "required variables not set"

	def required_set(self, variables):
		for variable in variables:
			if variables[variable][1] == "yes":
				if len(variables[variable][0]) <= 0:
					return False

		return True
