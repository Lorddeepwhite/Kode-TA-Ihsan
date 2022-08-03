# Module Imports
from genericpath import isfile
import sys
import os
from pathlib import Path
from datetime import date
from xml.etree.ElementTree import tostring
import pyparsing as pyp
import itertools
from itertools import islice
import schedule
import time

import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
# Fetch the service account key JSON file contents
cred = credentials.Certificate('/home/ihsanfr/Kode_TA_Ihsan/Firebase/ta-ihsan-firebase-adminsdk-dqlgz-233439b4b0.json')
# Initialize the app with a service account, granting admin privileges
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://ta-ihsan-default-rtdb.firebaseio.com/'
})

ref = db.reference('snort_log')


def add_data(SID, Pesan_Alert, Prioritas, Timestamp, Port, IP_Address, IP, Paket_Input_Output, Exploit):
    value = {
        "SID" : SID,
        "Pesan_Alert" : Pesan_Alert,
        "Prioritas" : Prioritas,
        "Timestamp" : Timestamp,
        "Port" : Port,
        "IP_Address" : IP_Address,
        "IP" : IP,
        "Paket_Input_Output" : Paket_Input_Output,
        "Exploit" : Exploit
    }
    ref.push().set(value)

integer = pyp.Word(pyp.nums)
string = pyp.Word(pyp.alphas)
ip_addr = pyp.Combine(integer+'.'+integer+'.'+integer+'.'+integer)

def snort_parse(logfile, baris_awal):
    header = (pyp.Suppress("[**] [" + integer + ":")
              + pyp.Combine(integer)
              )
    cls = ( pyp.Suppress(":" + integer +"]") +
        pyp.Regex("[^[]*") +pyp.Suppress("[**]"))
    
    pri = pyp.Suppress("[Priority:") + integer + pyp.Suppress("]")
    date = pyp.Combine(
        integer+"/"+integer+'-'+integer+':'+integer+':'+integer+'.'+integer)
    network = pyp.Combine(ip_addr + pyp.SkipTo("-> ", include = True) + ip_addr) 
    port =  pyp.Combine(pyp.Suppress(":") + integer +pyp.Suppress("\n"))
    ip = (pyp.Regex("([A-Z])\w+") +pyp.Suppress("TTL") )
    desk = (pyp.Suppress("* ") + pyp.Regex("(.+)+") )

    bnf = header +cls +pri + date+ network+port
    
    n_line = 0
    with open(logfile, 'r') as snort_logfile:
        n_line = len(snort_logfile.readlines())
        print(n_line)
    with open(logfile, 'r') as snort_logfile:
        for grp in islice(snort_logfile, baris_awal, None):
            for has_content, grp in itertools.groupby(snort_logfile, key = lambda x: bool(x.strip())):
                if has_content:
                    tmpStr = ''.join(grp)
                    id = header.searchString(tmpStr)
                    kelas = cls.searchString(tmpStr)
                    prior = pri.searchString(tmpStr)
                    tgl = date.searchString(tmpStr)
                    jaringan = network.searchString(tmpStr)
                    plbhn = port.searchString(tmpStr)
                    ips = ip.searchString(tmpStr)
                    deskripsi = desk.searchString(tmpStr)
                    strippedid = str(id).replace("[['", "").replace("']]", "")
                    strippedkelas = str(kelas).replace("[['", "").replace("']]", "")
                    strippedprior = str(prior).replace("[['", "").replace("']]", "")
                    strippedtgl = str(tgl).replace("[['", "").replace("']]", "")
                    strippedjaringan = str(jaringan).replace("[['", "").replace("']]", "")
                    strippedplbhn = str(plbhn).replace("[['", "").replace("']]", "")
                    strippedip = str(ips).replace("[['", "").replace("']]", "")
                    strippeddeskripsi = str(deskripsi).replace("[['", "").replace("']]", "")
                    if "decode fails" in strippeddeskripsi:
                        ErrorDB = "Upload Ejbca"
                    elif "Invalid DN" and "':" in strippeddeskripsi:
                        ErrorDB = "SQL Injection"
                    elif "<script>" in strippeddeskripsi:
                        ErrorDB = "XSS"
                    elif "Some chars stripped." in strippeddeskripsi and "<script>" not in strippeddeskripsi:
                        ErrorDB = "Command Injection"
                    else:
                        ErrorDB = "Non Exploit"
                    print(strippedid, strippedkelas, strippedprior, strippedtgl, strippedplbhn, strippedjaringan, strippedip, strippeddeskripsi, ErrorDB)
                    add_data(strippedid, strippedkelas, strippedprior, strippedtgl, strippedplbhn, strippedjaringan, strippedip, strippeddeskripsi, ErrorDB)

def length_file(filename):
    with open(filename) as f:
        for i, l in enumerate(f):
            pass
    return i + 1
    
def linecount(filename):
    with open (linecountpath, "r+") as lc:
        if os.stat(linecountpath).st_size == 0:
            lc.truncate(0)
            lc.seek(0)
            lc.write("0")
        else:
            i = length_file(filename)
            lc.truncate(0)
            lc.seek(0)
            lc.write(str(i))

linecountpath = "/home/ihsanfr/Kode_TA_Ihsan/Firebase/snortlinecount.txt"
my_file = Path(linecountpath)
if not my_file.is_file():
    with open (linecountpath, "w") as lc:
        lc.write("0")

from_line = 0
with open(linecountpath, "r") as f :
    from_line = int(f.readline())
if isfile("/home/ihsanfr/Kode_TA_Ihsan/alert1.txt"):
    linecount("/home/ihsanfr/Kode_TA_Ihsan/alert1.txt")
    snort_parse("/home/ihsanfr/Kode_TA_Ihsan/alert1.txt", from_line)
else:
    print("A09:2021 - Secure Logging and Monitoring Failures")