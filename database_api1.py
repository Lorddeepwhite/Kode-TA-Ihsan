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
from xml.etree.ElementTree import tostring
import pyparsing as pyp
import itertools
import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
# Connect to MariaDB Platform
def connect_firebase():
    cred = credentials.Certificate('/Firebase/ta-ihsan-firebase-adminsdk-dqlgz-233439b4b0.json')
    # Initialize the app with a service account, granting admin privileges
    firebase_admin.initialize_app(cred, {
        'databaseURL': 'https://ta-ihsan-default-rtdb.firebaseio.com/'
    })


def add_data_firebase_terminal(Tanggal, IsiLog):
    connect_firebase()
    ref = db.reference('terminal_log')
    value = {
        "Tanggal" : str(Tanggal),
        "IsiLog" : IsiLog
    }
    ref.push().set(value)

def add_data_firebase_ejbca(Tanggal, Timestamp, Log_Level, Event_Module, Server_Service_Thread_Port, Deskripsi_EventPaket_Input_Output, Tipe_Error):
    connect_firebase()
    ref = db.reference('EJBCA_log')
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

def add_data_firebase_snort(SID, Pesan_Alert, Prioritas, Timestamp, Port, IP_Address, IP, Paket_Input_Output, Exploit):
    connect_firebase()
    ref = db.reference('snort_log')
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

def connect_mariadb():
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
    return conn

# Get Cursor

def add_data_terminal(Tanggal, IsiLog, conn):
    cur = conn.cursor()
    try:
        statement = "INSERT INTO TerminalTable (Tanggal, IsiLog) VALUES (%s, %s)"
        data = (Tanggal, IsiLog)
        cur.execute(statement, data)
        conn.commit()
        print("Successfully added entry to database")
    except database.Error as e:
        print(f"Error adding entry to database: {e}")

def add_data_EJBCA(Tanggal, Timestamp, Log_Level, Event_Module, Server_Service_Thread_Port, Paket_Input_Output, Type_Error, conn):
    cur = conn.cursor()
    try:
         statement = "INSERT INTO EjbcaTable (Tanggal, Timestamp, Log_Level, Event_Module, Server_Service_Thread_Port, Deskripsi_Event_Input_Output, Type_Error) VALUES (%s, %s, %s, %s, %s, %s, %s)"
         data = (Tanggal, Timestamp, Log_Level, Event_Module, Server_Service_Thread_Port, Paket_Input_Output, Type_Error)
         cur.execute(statement, data)
         conn.commit()
         print("Successfully added entry to database")
    except database.Error as e:
         print(f"Error adding entry to database: {e}")

def add_data_snort(SID, Pesan_Alert, Prioritas, Timestamp, Port, IP_Address, IP, Paket_Input_Output, Exploit, conn):
    cur = conn.cursor()
    try:
        statement = "INSERT INTO SnortTable (SID, Pesan_Alert, Prioritas, Timestamp, Port, IP_Address, IP, Paket_Input_Output, Exploit) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)"
        data = (SID, Pesan_Alert, Prioritas, Timestamp, Port, IP_Address, IP, Paket_Input_Output, Exploit)
        cur.execute(statement, data)
        conn.commit()
        print("Successfully added entry to database")
    except database.Error as e:
        print(f"Error adding entry to database: {e}")

def parsing_ejbca(filepath, baris_awal, conn) :
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
            add_data_EJBCA(tanggal, timestamp, level, event_name, server_port, Deskripsi, ErrorDB, conn)
            add_data_firebase_ejbca(tanggal, timestamp, level, event_name, server_port, Deskripsi, ErrorDB)

def parsing_terminal(filepath, baris_awal, conn) :
    data = []
    n_line = 0
    with open(filepath, 'r') as fin:
        n_line = len(fin.readlines())
        print(n_line)
    with open(filepath, 'r') as fin:
        for line in islice(fin, baris_awal, None):
            start = 0
            end = start
            while end < len(line):
                end += 1
            Deskripsi = line[start:end]
            tanggal = date.today()
            print(tanggal, Deskripsi)
            add_data_terminal(tanggal, Deskripsi, conn)
            add_data_firebase_terminal(tanggal, Deskripsi)

def parsing_snort(logfile, baris_awal, conn):
    integer = pyp.Word(pyp.nums)
    string = pyp.Word(pyp.alphas)
    ip_addr = pyp.Combine(integer+'.'+integer+'.'+integer+'.'+integer)
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
                    #Kolom exploit
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
                    add_data_snort(strippedid, strippedkelas, strippedprior, strippedtgl, strippedplbhn, strippedjaringan, strippedip, strippeddeskripsi, ErrorDB, conn)
                    add_data_firebase_snort(strippedid, strippedkelas, strippedprior, strippedtgl, strippedplbhn, strippedjaringan, strippedip, strippeddeskripsi, ErrorDB)


def length_file(filename):
    with open(filename) as f:
        for i, l in enumerate(f):
            pass
    return i + 1

def linecount(filename, linecountpath):
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

def main_terminal():
    linecountpath = "linecountterminal.txt"
    conn1 = connect_mariadb()
    conn2 = connect_firebase()
    my_file1= Path(linecountpath)
    if not my_file1.is_file():
        with open (linecountpath, "w") as lc:
            lc.write("0")
    from_line = 0
    with open(linecountpath, "r") as f :
        from_line = int(f.readline())
    filepath1 = 'tes.log'

    if isfile(filepath1):
        linecount(filepath1)
        parsing_terminal(filepath1, from_line, conn1)
    else:
        print("A09:2021 - Secure Logging and Monitoring Failures")
    conn1.close()
    conn2.close()

def main_mariadb():
    conn = connect_mariadb
    linecountpath1 = "MariaDBtes/snortlinecount.txt"
    linecountpath2 = "MariaDB/linecount.txt"
    my_file1 = Path(linecountpath1)
    my_file2 = Path(linecountpath2)
    if not my_file1.is_file():
        with open (linecountpath1, "w") as lc:
            lc.write("0")
    if not my_file2.is_file():
        with open (linecountpath2, "w") as lc:
            lc.write("0")

    from_line1 = 0
    with open(linecountpath1, "r") as f :
        from_line1 = int(f.readline())
    if isfile("alert1.txt"):
        linecount("alert1.txt")
        parsing_snort("alert1.txt", from_line1, conn)
    else:
        print("A09:2021 - Secure Logging and Monitoring Failures")

    from_line2 = 0
    with open(linecountpath2, "r") as f :
        from_line2 = int(f.readline())
    if isfile('ejbca1.log'):
        linecount('ejbca1.log')
        parsing_ejbca('ejbca1.log', from_line2, conn)
    else:
        print("A09:2021 - Secure Logging and Monitoring Failures")
    conn.close()

def main_firebase():
    conn = connect_firebase
    linecountpath1 = "Firebase/snortlinecount.txt"
    linecountpath2 = "Firebase/linecount.txt"
    my_file1 = Path(linecountpath1)
    my_file2 = Path(linecountpath2)
    if not my_file1.is_file():
        with open (linecountpath1, "w") as lc:
            lc.write("0")
    if not my_file2.is_file():
        with open (linecountpath2, "w") as lc:
            lc.write("0")

    from_line1 = 0
    with open(linecountpath1, "r") as f :
        from_line1 = int(f.readline())
    if isfile("alert1.txt"):
        linecount("alert1.txt")
        parsing_snort("alert1.txt", from_line1, conn)
    else:
        print("A09:2021 - Secure Logging and Monitoring Failures")
        
    from_line2 = 0
    with open(linecountpath2, "r") as f :
        from_line2 = int(f.readline())
    if isfile('ejbca1.log'):
        linecount('ejbca1.log')
        parsing_ejbca('ejbca1.log', from_line2, conn)
    else:
        print("A09:2021 - Secure Logging and Monitoring Failures")

    conn.close()
