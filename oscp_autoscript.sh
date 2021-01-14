#!/bin/bash

# OSCP Automation script created by Mattia Campagnano on Mon 04 Jan 2021 08:58:23 PM EST
# Inspired by Joe McCray: https://www.youtube.com/watch?v=2dUXW-qhyGk

start_time=$(date)

echo -n "OSCP Automation Script started at $start_time"
echo

#####################################
# START NMAP SCAN ON ALL PORTS
#####################################
echo -n "Enter host list file: "
read hosts

echo -n "Enter CIDR first three octets: "
read CIDR


echo -n "Enter output file path: "
read output

nmap -sS -sV -T4 -A -vv -p- --open -iL $hosts -oA $output & 

echo "Full nmap scan completed"
echo

#########################################
# CREATE NEEDED DIRECTORIES
#########################################

mkdir -p /root/exam
mkdir -p /root/exam/discovered_services
mkdir -p /root/exam/discovered_services/windows/windows_scan
mkdir -p /root/exam/discovered_services/sunrpc/sunrpc_scan
mkdir -p /root/exam/discovered_services/ssh/ssh_scan
mkdir -p /root/exam/discovered_services/ftp/ftp_scan/
mkdir -p /root/exam/discovered_services/http/http_scan
mkdir -p /root/exam/discovered_services/https/https_scan
mkdir -p /root/exam/discovered_services/telnet/telnet_scan
mkdir -p /root/exam/discovered_services/pop3/pop3_scan
mkdir -p /root/exam/discovered_services/printers/printers_scan
mkdir -p /root/exam/discovered_services/mssql/mssql_scan
mkdir -p /root/exam/discovered_services/mysql/mysql_scan
mkdir -p /root/exam/discovered_services/mongodb/mongob_scan
mkdir -p /root/exam/discovered_services/nfs/nfs_scan
mkdir -p /root/exam/discovered_services/rdp/rdp_scan
mkdir -p /root/exam/discovered_services/smtp/smtp_scan
mkdir -p /root/exam/Autorecon

echo -n "All needed directories were successfully created"
echo

################################
PROPECIA INSTALL PROCESS
################################

# The following steps (lines 64-167) require installing propecia (a very fast service sweeper), if not already available on the PWK VM.

# PROPECIA INSTALLATION PROCESS
# a) git clone https://github.com/Wh1t3Rh1n0/propecia.py.git
# b) mv /root/propecia.py /root/propecia (I recommend renaming the script directory, "propecia.py", to "propecia", to avoid confusions)

#####################################
#WINDOWS HOSTS DISCOVERY
####################################
cd /root/propecia
echo
echo "$(pwd) is the current directory"
echo "Discovery of Windows hosts in progress..."
python propecia.py $CIDR 445 | tee /root/exam/discovered_services/windows/windows_hosts.txt

#####################################
#FTP HOSTS DISCOVERY
####################################
echo "Discovery of hosts running FTP in progress..."
python propecia.py $CIDR 21 |tee  /root/exam/discovered_services/ftp/ftp_hosts.txt

##################################
#SSH HOSTS DISCOVERY
#################################
echo "Discovery of hosts running SSH in progress..."
python propecia.py $CIDR 22 | tee /root/exam/discovered_services/ssh/ssh_hosts.txt

###############################
#RPC HOSTS DISCOVERY
##############################
echo "Discovery of hosts running RPC in progress..."
python propecia.py $CIDR 111 |tee  /root/exam/discovered_services/sunrpc/sunrpc_hosts.txt

##############################
#HTTP HOSTS DISCOVERY
#############################
echo "Discovery of hosts running HTTP in progress..."
python propecia.py $CIDR 80 | tee /root/exam/discovered_services/http/http_hosts.txt


##############################
#HTTPS HOSTS DISCOVERY
#############################
echo "Discovery of hosts running HTTPS in progress..."

python propecia.py $CIDR 443 | tee /root/exam/discovered_services/https/https_hosts.txt

#############################
#TELNET HOSTS DISCOVERY
############################

echo "Discovery of hosts running Telnet in progress..."
python propecia.py $CIDR 23 | tee /root/exam/discovered_services/telnet/telnet_hosts.txt

###########################
#POP3 HOSTS DISCOVERY
##########################

echo "Discovery of hosts running POP3 in progress..."
python propecia.py $CIDR 110 | tee /root/exam/discovered_services/pop3/pop3_hosts.txt

###########################
#PRINTERS DISCOVERY
##########################

echo "Discovery of network printers in progress..."
python propecia.py $CIDR 631 | tee /root/exam/discovered_services/printers/network_printers.txt

###########################
#MSSQL HOSTS DISCOVERY 
##########################

echo "Discovery of hosts running mssql in progress..."
python propecia.py $CIDR 1433 | tee /root/exam/discovered_services/mssql/mssql_hosts.txt


###########################
#MYSQL HOSTS DISCOVERY 
##########################

echo "Discovery of hosts running mysql in progress..."
python propecia.py $CIDR 3306 |tee /root/exam/discovered_services/mysql/mysql_hosts.txt


###########################
#MONGODB HOSTS DISCOVERY 
##########################

echo "Discovery of hosts running mongodb in progress..."
python propecia.py $CIDR 27017 | tee /root/exam/discovered_services/mongodb/mongodb_hosts.txt


###########################
#NFS HOSTS DISCOVERY 
##########################

echo "Discovery of hosts running nfs in progress..."
python propecia.py $CIDR 2049 | tee /root/exam/discovered_services/nfs/nfs_hosts.txt


###########################
#RDP HOSTS DISCOVERY 
##########################

echo "Discovery of hosts running RDP in progress..."
python propecia.py $CIDR 3389 |tee /root/exam/discovered_services/rdp/rdp_hosts.txt


###########################
#SMTP HOSTS DISCOVERY 
##########################
echo "Discovery of hosts running smtp in progress..."
python propecia.py $CIDR 25 |tee /root/exam/discovered_services/smtp/smtp_hosts.txt

#################################################
DEEP SERVICES ENUMERATION AND VULNERABILITY SCAN 
#################################################

for x in $(cat /root/exam/discovered_services/windows/windows_hosts.txt) ; do nmap -Pn -p 445 --open --script="smb-vuln* and not(brute or dos)","smb-enum* and not(brute or dos)","smb-os-discovery,smb-security-mode" $x -oA /root/exam/discovered_services/windows/windows_scan/SMB_scan_$x;done &
 

for x in $(cat /root/exam/discovered_services/ftp/ftp_hosts.txt) ; do nmap -Pn -p 21 --open --script "ftp-* and not(brute or dos)" $x -oA /root/exam/discovered_services/ftp/ftp_scan_$x;done &


for x in $(cat /root/exam/discovered_services/ssh/ssh_hosts.txt) ; do nmap -Pn -p 22 --open --script "ssh*-* and not(brute or dos)" $x -oA /root/exam/discovered_services/ssh/ssh_scan_$x;done &


for x in $(cat /root/exam/discovered_services/sunrpc/sunrpc_hosts.txt) ; do nmap -Pn -p 111 --open --script msrpc-enum.nse,rpc-grind.nse,rpcinfo.nse $x -oA /root/exam/discovered_services/sunrpc/sunrpc_scan_$x;done &

for x in $(cat /root/exam/discovered_services/http/http_hosts.txt) ; do nmap -Pn -p 80 --open --script "http-* and not (brute or dos)" $x -oA /root/exam/discovered_services/http/http_scan_$x;done &


for x in $(cat /root/exam/discovered_services/https/https_hosts.txt) ; do nmap -Pn -p 443 --open --script "ssl-*","sslv2*" $x -oA /root/exam/discovered_services/https/https_scan_$x;done &

for x in $(cat /root/exam/discovered_services/telnet/telnet_hosts.txt) ; do nmap -Pn -p 23 --open --script "telnet-* and not (brute or dos)" $x -oA /root/exam/discovered_services/telnet/telnet_scan_$x;done &


for x in $(cat /root/exam/discovered_services/pop3/pop3_hosts.txt) ; do nmap -Pn -p 110 --open --script "pop3-* and not (brute or dos)" $x -oA /root/exam/discovered_services/pop3/pop3_scan_$x;done &


for x in $(cat /root/exam/discovered_services/printers/network_printers.txt) ; do nmap -Pn -p 631 --open --script "cups-*" $x -oA /root/exam/discovered_services/printers_scan/printers_$x;done &

for x in $(cat /root/exam/discovered_services/mysql/mysql_hosts.txt) ; do nmap -Pn -p 3306 --open --script "mysql-* and not (brute or dos)"  $x -oA /root/exam/discovered_services/mysql/mysql_scan/mysql_$x;done &


for x in $(cat /root/exam/discovered_services/mongodb/mongodb_hosts.txt) ; do nmap -Pn -p 27017 --open --script "mongodb-*"  $x -oA /root/exam/discovered_services/mongodb/mongodb_scan/mongodb_$x;done &

for x in $(cat /root/exam/discovered_services/nfs/nfs_hosts.txt) ; do nmap -Pn -p 2049 --open --script "nfs-* and not (brute or dos)"  $x -oA /root/exam/discovered_services/nfs/nfs_scan/nfs_$x;done &

for x in $(cat /root/exam/discovered_services/rdp/rdp_hosts.txt) ; do nmap -Pn -p 3389 --open --script "rdp-* and not (brute or dos)"  $x -oA /root/exam/discovered_services/rdp/rdp_scan/rdp_$x;done &

for x in $(cat /root/exam/discovered_services/smtp/smtp_hosts.txt) ; do nmap -Pn -p 25 --open --script "smtp-* and not (brute or dos)"  $x -oA /root/exam/discovered_services/smtp/smtp_scan/smtp_$x;done &

sleep 1

#####################################
# RUN AUTORECON SCRIPT
####################################

# if you don't have AutoRecon already installed to your VM, run the simple command below to clone the repo:
# git clone https://github.com/Tib3rius/AutoRecon.git
# To install AutoRecon, follow the detailed setup guide available on the GitHub repo.

cd /root/AutoRecon/src/autorecon
python3 autorecon.py -t $hosts -o /root/exam/Autorecon &

echo -n "Running Autorecon script on all targets..."
echo
echo
echo
echo -n "Please check results, remember to run Burp Community Edition on all http and https hosts discovered"
echo

######################################
#COMPLETE WORK AND EXIT THE PROGRAM
#####################################

end_time=$(date)

echo "OSCP Automation Script terminated at $end_time"

cd /root/exam


