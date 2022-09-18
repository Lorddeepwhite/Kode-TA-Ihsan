import os
import sys
import apt
import subprocess

def curl(path):
    sys.stdout = open(path, "a")
    command = "curl -v -s --tlsv1.1 https://localhost:8442/ejbca -o /dev/null/ 2>&1; curl -v -s --tlsv1.2 https://localhost:8442/ejbca -o /dev/null/ 2>&1; curl -v -s --tlsv1.3 https://localhost:8442/ejbca -o /dev/null/ 2>&1; apt list --upgradable"
    r = os.popen(command)
    info = r.readlines()
    for line in info:  
        line = line.strip('\r\n')
        print(line)
