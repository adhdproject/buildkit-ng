import subprocess
import os
import core.database

class bootstrap:
	
	def __init__(self, force=False):
		#self._install_requirements(force)
		es = core.database.essential()
		da = core.database.dbadmin()

		return

	def _install_requirements(self, force=False):
		if not os.path.isfile("conf/.installed_requiements") or force:
			subprocess.check_output("pip install -r REQUIREMENTS.txt", shell=True)
			subprocess.check_output("touch conf/.installed_requirements", shell=True)
