# Module Imports
from genericpath import isfile
import sys
from itertools import islice
import os
from pathlib import Path
from datetime import date
import schedule
import time

import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
# Fetch the service account key JSON file contents
cred = credentials.Certificate('ta-ihsan-firebase-adminsdk-dqlgz-233439b4b0.json')
# Initialize the app with a service account, granting admin privileges
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://ta-ihsan-default-rtdb.firebaseio.com/'
})

ref = db.reference('EJBCA_log')

# Add To Firebase
def add_data(Tanggal, Timestamp, Log_Level, Event_Module, Server_Service_Thread_Port, Deskripsi_EventPaket_Input_Output, Tipe_Error):
    value = {
        "Tanggal": str(Tanggal),
        "Timestamp":str(Timestamp), 
        "Log_Level":str(Log_Level), 
        "Event_Module":str(Event_Module),
        "Server_Service_Thread_Port":str(Server_Service_Thread_Port),
        "Deskripsi_EventPaket_Input_Output":str(Deskripsi_EventPaket_Input_Output),
        "Tipe_Error":str(Tipe_Error)
    }    
    ref.push().set(value)
    
    
def parsing(filepath, baris_awal) :
    data = []
    n_line = 0
    with open(filepath, 'r') as fin:
        n_line = len(fin.readlines())
        print(n_line)
    with open(filepath, 'r') as fin:
        for line in islice(fin, baris_awal, None):
            start = 0
            end = start
            #untuk kolom timestamp
            while line[end] != " " :
                end += 1
                
            timestamp = line[start:end]

            #untuk kolom log_level
            start = end
            while line[start] == " " :
                start += 1
                
            end = start
            while line[end] != " " :
                end += 1
            level = line[start:end]

            #untuk kolom event module
            start = end
            while line[start] == " " :
                start += 1
                
            end = start
            while line[end] != "]" :
                end += 1
            event_name = line[start+1:end]

            #untuk kolom server port
            start = end
            while line[start] == "(" :
                start += 1
                
            end = start
            while line[end] != ")" :
                end += 1
            server_port = line[start+3:end]

            #untuk kolom deskripsi
            start = end
            while line[start] == " " :
                start += 1
            end = start
            while end < len(line):
                end += 1
            Deskripsi = line[start+2:end]

            #untuk kolom tanggal
            tanggal = date.today()
            if "decode fails" in Deskripsi:
                ErrorDB = "Upload Ejbca"
            elif "Invalid DN" and "':" in Deskripsi:
                ErrorDB = "SQL Injection"
            elif "<script>" in Deskripsi:
                ErrorDB = "XSS"
            elif "Some chars stripped." in Deskripsi and "<script>" not in Deskripsi:
                ErrorDB = "Command Injection"
            else:
                ErrorDB = "Non Exploit"
            print((tanggal, timestamp, level, event_name, server_port, Deskripsi, ErrorDB))
            add_data(tanggal, timestamp, level, event_name, server_port, Deskripsi, ErrorDB)
            
            
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


script_dir = os.path.dirname(__file__)
linecountpath_rel = "linecount.txt"
linecountpath = os.path.join(script_dir, rel_path)
my_file = Path(linecountpath)
if not my_file.is_file():
    with open (linecountpath, "w") as lc:
        lc.write("0")
        
from_line = 0
with open(linecountpath, "r") as f :
    from_line = int(f.readline())
filepath1 = '/Kode_TA_Ihsan/ejbca1.log'


if isfile(filepath1):
    linecount(filepath1)
    parsing(filepath1, from_line)
else:
    print("A09:2021 - Secure Logging and Monitoring Failures")
# schedule.every(5).seconds.do(lambda: linecount(filepath1))
# schedule.every(10).seconds.do(lambda: parsing(filepath1, from_line))
# while 1:
#     schedule.run_pending()
#     time.sleep(1)    
