#!/usr/bin/env python

from Crypto.Hash import SHA, SHA224, SHA256, SHA384, SHA512
from Crypto.Cipher import AES
from Crypto import Random

import os

FILE_LOCAL = 0
DATA_LEN = 32

class auth:
	
	
	supported_hashing_algorithms = [SHA,SHA224,SHA256,SHA384,SHA512]


	def __init__(self, pointerlengths, filename=None, source=FILE_LOCAL, algo=SHA256, datalen=DATA_LEN):
		self.init = True
		if source == FILE_LOCAL and filename == None:
			raise Exception("Source: %s requires the filename argument to be set" % FILE_LOCAL)
		
		self.pointerlengths = pointerlengths
		if type(pointerlengths) != list:
			raise Exception("Pointerlengths: must be a list, one length per pointer")
		self.source = source
		if self.source > 0:
			raise Exception("Source: not yet implemented")


		self.filename = filename
		self.algo = algo
		self.DATA_LEN = datalen

	def unpack(self, key, inp, algo=SHA256, passes=1):
		if algo in self.supported_hashing_algorithms:
			for i in xrange(passes):
				h = algo.new()
				h.update(key)
				key = h.hexdigest()

		if not ":::" in inp:
			return "Error: missing initialization vector"

		iv, ct = inp.split(":::")
		cipher = AES.new(key.decode('hex'), AES.MODE_CFB, iv.decode('hex'))
		
		return cipher.decrypt(ct.decode('hex')).encode('hex')
		

	def generate(self, key, algo=SHA256, passes=1):		


		if algo in self.supported_hashing_algorithms:
			for i in xrange(passes):
				h = algo.new()
				h.update(key)
				key = h.hexdigest().decode('hex')

		temp_data = []

		poinlen = 0
		for i in xrange(len(self.pointerlengths)):
			poinlen += int(self.pointerlengths[i])
			
		if poinlen % 8 != 0:
			poinlen += 8 - poinlen % 8
				
		
		temp_pointers = Random.new().read(poinlen/8)

		temp = bin( int (temp_pointers.encode('hex'), 16) )
		temp = temp[2:]
		for i in xrange(len(self.pointerlengths)):
			pointer = temp[0:int(self.pointerlengths[i])]
			temp = temp[int(self.pointerlengths[i]):]
			
			pointer = int(pointer, 2)
			temp_data.append(self._get(pointer, self.DATA_LEN))
		
		h = self.algo.new()
		h.update("".join(temp_data))
		hashval = h.hexdigest()
		data = "".join(temp_pointers) + hashval.decode('hex')


		iv = Random.new().read( AES.block_size)
		cipher = AES.new(key, AES.MODE_CFB, iv)
		output = iv.encode('hex') + ":::" + cipher.encrypt(data).encode('hex')

		return output

		
		


	def authenticate(self, plaintext):
		
		try:
			plaintext.decode('hex')
		except:
			return "Error: plaintext not formatted as hex"

		temp = []
		cur = 0
		pointers = []

		poinlen = 0
		for i in self.pointerlengths:
			poinlen += int(i)

		if poinlen % 8 != 0:
			poinlen += 8 - poinlen % 8

		pointerhalf = bin( int(plaintext[0:poinlen/4], 16) )[2:]
		hashval = plaintext[poinlen/4:]
		
		for i in self.pointerlengths:
			pointers.append(pointerhalf[0:int(i)])
			pointerhalf = pointerhalf[int(i):]

		for pointer in pointers:
			temp.append(self._get(int(pointer, 2), self.DATA_LEN))

		h = self.algo.new()
		h.update("".join(temp))
		hashtry = h.hexdigest()
		return hashtry == hashval
		

	def _get(self, pointer, length):
		if type(pointer) != int and type(pointer) != long:
			raise Exception("Pointer: must be an int value already")
		if self.source == FILE_LOCAL:
			fi = open(self.filename, "r")
			fi.seek(pointer)
			out = fi.read(int(length))
			fi.close()
			if out == '':
				raise Exception("Pointer is outside of array")
			return out
				
		
		raise Exception("Invalid source specified")
		return 

	
