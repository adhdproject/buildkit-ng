#OpenBAC Library Documentation

##Description
OpenBAC implements the Ball and Chain algorithm to securely store passwords.

OpenBAC includes documentation, utilities, and code you can use in your projects.  This way you can implement Ball and Chain without having to write your own version of the algorithm into code.

OpenBAC is open source and subject to scrutiny and audit by anyone and everyone.  If you find anything wrong with the code simply contact me [@zaeyx](https://twitter.com/zaeyx) and I will patch it and add you to the list of contributors to the project.

This file describes the features of the library itself (openbac.py)

I've currently only written a python library.  But that is subject to change in the future.  We have plans for more implementations.

##Globals

**`FILE_LOCAL = 0`** ==> This maps the storage mechanism for the array.

**`DATA_LEN = 32`** ==> This is the amount of data taken from each pointer.

##The Auth Class
The auth class implements everything you need to be able to generate hash values and perform authentication.

The supported hashing algorithms are listed under **`auth.supported_hashing_algorithms`**

After importing openbac into your code (**`import openbac`**) you can create an instance of the auth class like so:

```python 
		a = openbac.auth(pointerlengths, filename)
```

The definition for the init class of auth is as follows:

```python
		def __init__(self, pointerlengths, filename=None, source=FILE_LOCAL, algo=SHA256, datalen=DATA_LEN):
```

You can set any of these values when you instantiate the auth class.  But you're going to need to set pointerlengths and filename for sure (as long as you're using source=FILE_LOCAL, which is currently the only implemented source).

**`filename`** ==> a string pointing to the arrayfile.

**`pointerlengths`** ==> a list of int values (stored as strings) one per pointer.

You can set these values however you want;  server.py reads these values in from the file openbac.conf.  You could easily just read them in from there in the way that server.py does too.

The other variable are:

**`source`** ==> the source to use to find the array. Don't change this for now.

**`algo`** ==> the algorithm to hash the datastream with.

**`datalen`** ==> the length of data to pull from each location in the array.

Once you've created your instance of the auth object you can call it's functions.

Currently there are three main functions you'll want to know (and a few helper functions you shouldn't worry about).

These are:

	* unpack
	* authenticate
	* generate


###Unpack
**unpack** is defined as follows:

```python
def unpack(self, key, inp, algo=SHA256, passes=1):
```

It takes as input the user's key in plaintext and the stored password "hash" as created by the generate function.  It then unpacks the hash and passes the results back to you.

**`key`** ==> the user's password

**`inp`** ==> the user's hash from your password file or db

**`algo`** ==> the algo to hash the key with before decryption

**`passes`** ==> the number of times to hash the key

You can keep the defaults.  You only need to set the key and inp values.

For example:

```python
		plaintext = a.unpack("mypasswd", "9f9cc32a374ebb667c4bf7511a066f5d:::4a093032185582e225314bb69e5683f1e7d478d64280b0418e05447600be87dc1557dfd970bfff01427f30583ccc")
```

###Authenticate
**authenticate** is defined as follows:

```python
		def authenticate(self, plaintext):
```

All you need to do is pass the plaintext (like the one output by `unpack`) to authenticate, and as long as your auth instance is correctly linked to your array and all the settings are good it will be able to tell you if the user input the proper password or not.

Authenticate is the method that implements the pointer:data lookups described in under_the_hood.md and passes back a result to you.

You could use it like so (using the output from a.unpack() above):

```python
		isallowed = a.authenticate(plaintext)
```

If the user is allowed and the password correct, authenticate will return True.  Otherwise it will return False.

It's actually that easy.


###Generate
Finally, let's discuss the generate method.

The generate method is defined as follows:

```python
		def generate(self, key, algo=SHA256, passes=1):
```

Like the other methods in the auth class it requires the variables set during initialization to be correct.  That is, it has to be linked to the right file, with the right source, etc.

Also, if you decide to change the default values for algo and passes here make sure you also change them to the same values when you call `unpack` later, otherwise it's not going to work.

Generate takes the user's password (key) and returns the iv+hash object in the format iv+":::"+hash (you'll see it as one long hex encoded string with three colons somewhere near the front).

The variables are:

**`key`** ==> The user's password

**`algo`** ==> the hashing algorithm to process the password with before encryption.

**`passes`** ==> the number of passes of hashing to make on the key before encryption


You really only need to set the key though.  The defaults are going to be fine for 99.9% of cases.

An example call would be (assuming you already have your auth instance "a"):

```python
		passwd = raw_input("Enter your password: ")
		hash = a.generate(passwd)
```

You can then store the hash in whatever format you'd like.  Perhaps in a database, perhaps in a file in passwd/shadow format.

###In conclusion
That's all you really need to know about the library for now.  Check out some of the other docs to learn more about the Ball and Chain algorithm, password policies, the utilities included with this library, and more.
