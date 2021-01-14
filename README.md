<b> OSCP AUTOMATION SCRIPT by Mattia Campagnano (The_S@vvyG33k) </b>
<br> Tested on the official PWK VMware VM </br>

This script will perform automated recon on a target list, more exactly it will: 
</br> a) Perform a full Nmap scan on all ports on the target hosts<br> b) Determine which services are running on any given port</br> c) Run Nmap scripts specific to each services (smb, nfs, snmp, etc.) </br>
d) Run AutoRecon on all targets

<b>Requirements</b>:
</br> a) propecia.py 
</br> b) AutoRecon

<b>INSTALLING PROPECIA</b> <br>
a) git clone https://github.com/Wh1t3Rh1n0/propecia.py.git <br> b) mv /root/propecia.py /root/propecia (I recommend renaming the script directory, "propecia.py", to "propecia", to avoid confusions) </br>

<b>INSTALLING AUTORECON</b> <br>
  
COMMAND: <br> git clone https://github.com/Tib3rius/AutoRecon.git </br>
Installation guide: <br> https://github.com/Tib3rius/AutoRecon </br>

