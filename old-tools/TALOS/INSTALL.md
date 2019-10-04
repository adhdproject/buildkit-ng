####Installation is quite simple.
You'll need pip, a compatible python. and the required libraries (in REQUIREMENTS.txt)

`apt-get -y install python-pip`
`pip install -r REQUIREMENTS.txt`

NOTE:
	If yout launch `talos.py` prior to performing this, the script will attempt to install everything it needs automatically.

You may run into issues with installing the Talos depedencies.  If this happens make sure you have the right header files.
Example header installations might look something like this (depending on your situation).

`apt-get -y install libssl-dev python-dev`

If you are still having trouble getting everything to work correctly, one trick is to uninstall the Talos dependencies like so

`pip uninstall -r REQUIREMENTS.txt`

Then install the necessary dependencies through your system's package manager/repo system.

`apt-get install python-twisted python-service-identity python-paramiko python-netaddr`

Make sense?

Please direct any questions to me on twitter @zaeyx.

If you cannot get Talos installed, I want to hear about it.
