# Module Imports
import mariadb
import sys
import mysql.connector as database
from itertools import islice
import os
from pathlib import Path
from datetime import date

#checks if linecount.txt file exists. 
#if it doesn't exist a file is created and 0 is stored.
linecountpath = "/home/ihsanfr/Kode_TA_Ihsan/linecount.txt"
fileA = "/home/ihsanfr/Kode_TA_Ihsan/ejbca1.log"
my_file = Path(linecountpath)

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

def add_data(Tanggal, Timestamp, Log_Level, Event_Module, Server_Service_Thread_Port, Deskripsi_EventPaket_Input_Output):
    try:
        statement = "INSERT INTO EjbcaTable (Tanggal, Timestamp, Log_Level, Event_Module, Server_Service_Thread_Port, Deskripsi_EventPaket_Input_Output) VALUES (%s, %s, %s, %s, %s, %s)"
        data = (Tanggal, Timestamp, Log_Level, Event_Module, Server_Service_Thread_Port, Deskripsi_EventPaket_Input_Output)
        cur.execute(statement, data)
        conn.commit()
        print("Successfully added entry to database")
    except database.Error as e:
        print(f"Error adding entry to database: {e}")

if my_file.is_file():
    #donothing
    pass
else:
    with open (linecountpath, "w") as lc:
        lc.write("0")
       
#read lines from file A from nth line
    with open(fileA, 'r', errors='ignore') as f:
        with open (linecountpath, "r") as lc:
            b=lc.read()
            for line in islice(f, 5, None):
                line = line.replace('<br />')
            start = 0
            end = start

            while line[end] != " " :
                end += 1
                
            timestamp = line[start:end]
            start = end

            # space
            while line[start] == " " :
                start += 1
                
            end = start
            while line[end] != " " :
                end += 1
            level = line[start:end]

            start = end
            # space
            while line[start] == " " :
                start += 1
                
            # Bracketing
            end = start
            while line[end] != "]" :
                end += 1
            event_name = line[start+1:end]

            # Bracketing
            start = end

            while line[start] == "(" :
                start += 1
                
            end = start
            while line[end] != ")" :
                end += 1
            server_port = line[start+3:end]

            #Tab (masih terpotong line yang setelah ':')
            start = end
            while line[start] == " " :
                start += 1
            end = start
            while end < len(line):
                end += 1
            Deskripsi = line[start+2:end]
            tanggal = date.today()
            print((tanggal, timestamp, level, event_name, server_port, Deskripsi))
            add_data(tanggal, timestamp, level, event_name, server_port, Deskripsi)
                

#getting the nth line number form a large file 
def length_file(filename):
    with open(filename) as f:
        for i, l in enumerate(f):
            pass
    return i + 1
#writing line count into linecount.txt 
with open (linecountpath, "r+") as lc:
    if os.stat(linecountpath).st_size == 0:
        lc.truncate(0)
        lc.seek(0)
        lc.write("0")
    else:
        i = length_file(fileA)
        lc.truncate(0)
        lc.seek(0)
        lc.write(str(i))
conn.close()    
