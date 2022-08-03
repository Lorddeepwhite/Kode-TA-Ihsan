# Module Imports
from genericpath import isfile
import mariadb
import sys
import mysql.connector as database
from itertools import islice
import os
from pathlib import Path
from datetime import date
import time

script_dir = os.path.dirname(__file__)
linecountpath_rel = "linecount.txt"
linecountpath = os.path.join(script_dir, rel_path)
# Connect to MariaDB Platform
try:
    conn = mariadb.connect(
        user="dfr",
        password="dfr",
        host="localhost",
        port=3306,
        database="dfr"

    )
except mariadb.Error as e:
    print(f"Error connecting to MariaDB Platform: {e}")
    sys.exit(1)

# Get Cursor
cur = conn.cursor()

def add_data_EJBCA(Tanggal, Timestamp, Log_Level, Event_Module, Server_Service_Thread_Port, Paket_Input_Output, Type_Error):
    try:
        statement = "INSERT INTO EjbcaTable (Tanggal, Timestamp, Log_Level, Event_Module, Server_Service_Thread_Port, Deskripsi_Event_Input_Output, Type_Error) VALUES (%s, %s, %s, %s, %s, %s, %s)"
        data = (Tanggal, Timestamp, Log_Level, Event_Module, Server_Service_Thread_Port, Paket_Input_Output, Type_Error)
        cur.execute(statement, data)
        conn.commit()
        print("Successfully added entry to database")
    except database.Error as e:
        print(f"Error adding entry to database: {e}")


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
                ErrorDB = "Not Error"
            print((tanggal, timestamp, level, event_name, server_port, Deskripsi, ErrorDB))
            add_data_EJBCA(tanggal, timestamp, level, event_name, server_port, Deskripsi, ErrorDB)

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

my_file = Path(linecountpath)
if not my_file.is_file():
    with open (linecountpath, "w") as lc:
        lc.write("0")

from_line = 0
with open(linecountpath, "r") as f :
    from_line = int(f.readline())
filepath1 = 'Kode_TA_Ihsan/ejbca1.log'

if isfile(filepath1):
    linecount(filepath1)
    parsing(filepath1, from_line)
else:
    print("A09:2021 - Secure Logging and Monitoring Failures")
#schedule.every(5).seconds.do(lambda: linecount(filepath1))
#schedule.every(10).seconds.do(lambda: parsing(filepath1, from_line))
#while 1:
#    schedule.run_pending()
#    time.sleep(1) 
#conn.close()   

