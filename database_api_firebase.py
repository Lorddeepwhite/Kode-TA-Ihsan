# Module Imports
from genericpath import isfile
from socketserver import DatagramRequestHandler
import mariadb
import sys
import mysql.connector as database
from itertools import islice
import os
from pathlib import Path
from datetime import date, datetime
import time
from xml.etree.ElementTree import tostring
import pyparsing as pyp
import itertools
import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
# Connect to MariaDB Platform
def connect_firebase():
    if not firebase_admin._apps:
        cred = credentials.Certificate('/home/ihsanfr/Kode_TA_Ihsan/Firebase/ta-ihsan-firebase-adminsdk-dqlgz-233439b4b0.json')
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

def add_data_serverlog(Tanggal, Timestamp, Log_Level, Event_Module, Server_Service_Thread_Port, Deskripsi_EventPaket_Input_Output, Komponen):
    connect_firebase()
    ref = db.reference('Server_log')
    value = {
        "Tanggal": str(Tanggal),
        "Timestamp":str(Timestamp), 
        "Log_Level":str(Log_Level), 
        "Event_Module":str(Event_Module),
        "Server_Service_Thread_Port":str(Server_Service_Thread_Port),
        "Deskripsi_EventPaket_Input_Output":str(Deskripsi_EventPaket_Input_Output),
        "Komponen":str(Komponen)
    }    
    ref.push().set(value)

def add_data_log_failure(Date, line_error, path):
    connect_firebase()
    ref = db.reference('monitoring_failure_log')
    value = {
        "Tanggal" : str(Date),
        "Pesan_Kesalahan" : str(line_error),
        "Filepath" : str(path)
    }
    ref.push().set(value)

def add_data_non_exploit(Jumlah):
    connect_firebase()
    ref = db.reference('non_exploit')
    value = {
        "Jumlah Data" : str(Jumlah)
    }
    ref.push().set(value)

def add_data_total_deteksi(Banyak):
    connect_firebase()
    ref = db.reference('total_detection')
    value = {
        "Jumlah Data" : str(Banyak)
    }
    ref.push().set(value)

def parsing_ejbca(filepath, baris_awal) :
    data = []    
    n = 0
    jumlah = 0
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
                ErrorDB = "Upload Error (Broken Access Control)"
            elif "Invalid DN" and "':" in Deskripsi:
                ErrorDB = "SQL Injection (Injection)"
            elif "<script>" in Deskripsi:
                ErrorDB = "XSS (Injection/SSRF)"
            elif "Some chars stripped." in Deskripsi and "<script>" not in Deskripsi:
                ErrorDB = "Command Injection (Injection)"
            elif "brute force" in Deskripsi:
                    ErrorDB ="Brute Force Attempt (Security Misconfiguration)"
            else:
                ErrorDB = "Not Error"
            jumlah = jumlah + 1
            if "Not Error" in ErrorDB:
                n = n + 1
            if ErrorDB != "Not Error" :
                print((tanggal, timestamp, level, event_name, server_port, Deskripsi, ErrorDB))
                add_data_firebase_ejbca(tanggal, timestamp, level, event_name, server_port, Deskripsi, ErrorDB)
    add_data_non_exploit(n)
    add_data_total_deteksi(jumlah)

def parsing_terminal(filepath, baris_awal) :
    tanggal = datetime.today()
    n = 0
    jumlah = 0
    n_line = 0
    with open(filepath, 'r') as snort_logfile:
        n_line = len(snort_logfile.readlines())
        print(n_line)
    with open(filepath, 'r') as fin:
        for line in islice(fin, baris_awal, None):
            if "TLS" in line:
                print(tanggal, line)
                add_data_firebase_terminal(tanggal,line)
            elif "apache2" in line:
                print(tanggal, line)
                add_data_firebase_terminal(tanggal,line)

def parsing_snort(filepath, baris_awal):
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
    n = 0
    jumlah = 0
    n_line = 0
    with open(filepath, 'r') as snort_logfile:
        n_line = len(snort_logfile.readlines())
        print(n_line)
    with open(filepath, 'r') as snort_logfile:
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
                    if "decode fails" in strippedkelas:
                        ErrorDB = "Upload Error (Broken Access Control)"
                    elif "SQL" in strippedkelas:
                        ErrorDB = "SQL Injection (Injection)"
                    elif "XSS" in strippedkelas:
                        ErrorDB = "XSS (Injection/SSRF)"
                    elif "Some chars stripped." in strippedkelas and "<script>" not in strippedkelas:
                        ErrorDB = "Command Injection (Injection)"
                    elif "Brute Force" in strippedkelas:
                        ErrorDB ="Brute Force Attempt (Security Misconfiguration)"
                    else: 
                        ErrorDB = "Non Exploit"
                    jumlah = jumlah + 1
                    if "Non Exploit" in ErrorDB:
                        n = n + 1
                    if ErrorDB != "Non Exploit":
                        print(strippedid, strippedkelas, strippedprior, strippedtgl, strippedplbhn, strippedjaringan, strippedip, strippeddeskripsi, ErrorDB)
                        add_data_firebase_snort(strippedid, strippedkelas, strippedprior, strippedtgl, strippedplbhn, strippedjaringan, strippedip, strippeddeskripsi, ErrorDB)
    add_data_non_exploit(n)
    add_data_total_deteksi(jumlah)

def parsing_server(filepath, baris_awal) :
    data = []
    n = 0
    jumlah = 0
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
                
            tanggal = line[start:end]

            start = end
            while line[start] == " " :
                start += 1
                
            end = start
            while line[end] != " " :
                end += 1
            timestamp = line[start:end]

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

            runtime = "runtime-name: "
            module = Deskripsi[Deskripsi.index(runtime) + len(runtime):]
            print((tanggal, timestamp, level, event_name, server_port, Deskripsi, module))
            add_data_serverlog(tanggal, timestamp, level, event_name, server_port, Deskripsi, module)
    

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

def main_ejbca(filepath1):
    linecountpath = "/home/ihsanfr/Kode_TA_Ihsan/linecount/ejbcalinecount.txt"
    my_file = Path(linecountpath)
    errorline = "A09:2021 - Secure Logging and Monitoring Failures"
    acceptedline = "Secure Logging and Monitoring Detected"
    if not my_file.is_file():
        with open (linecountpath, "w") as lc:
            lc.write("0")
            
    from_line = 0
    with open(linecountpath, "r") as f :
        from_line = int(f.readline())

    tanggal = date.today()
    if isfile(filepath1):
        linecount(filepath1, linecountpath)
        parsing_ejbca(filepath1, from_line)
        add_data_log_failure(tanggal, acceptedline,filepath1)
    else:
        print(errorline)
        add_data_log_failure(tanggal, errorline, filepath1)

def main_snort(filepath1):
    linecountpath = "/home/ihsanfr/Kode_TA_Ihsan/linecount/snortlinecount.txt"
    my_file = Path(linecountpath)
    errorline = "A09:2021 - Secure Logging and Monitoring Failures"
    acceptedline = "Secure Logging and Monitoring Detected"
    if not my_file.is_file():
        with open (linecountpath, "w") as lc:
            lc.write("0")
    tanggal = date.today()
    from_line = 0
    with open(linecountpath, "r") as f :
        from_line = int(f.readline())
    if isfile(filepath1):
        linecount(filepath1, linecountpath)
        parsing_snort(filepath1, from_line)
        add_data_log_failure(tanggal, acceptedline,filepath1)
    else:
        print(errorline)
        add_data_log_failure(tanggal, errorline, filepath1)

def main_server():
    linecountpath = "/home/ihsanfr/Kode_TA_Ihsan/linecount/serverlinecount.txt"
    my_file = Path(linecountpath)
    errorline = "A09:2021 - Secure Logging and Monitoring Failures"
    acceptedline = "Secure Logging and Monitoring Detected"
    if not my_file.is_file():
        with open (linecountpath, "w") as lc:
            lc.write("0")
    tanggal = date.today()
    from_line = 0
    filepath1 = "/home/ihsanfr/Kode_TA_Ihsan/server.log"
    with open(linecountpath, "r") as f :
        from_line = int(f.readline())
    if isfile(filepath1):
        linecount(filepath1, linecountpath)
        parsing_server(filepath1, from_line)
        add_data_log_failure(tanggal, acceptedline,filepath1)
    else:
        print(errorline)
        add_data_log_failure(tanggal, errorline, filepath1)

def main_terminal(filepath1):
    linecountpath = "/home/ihsanfr/Kode_TA_Ihsan/linecount/linecountterminal_firebase.txt"
    my_file = Path(linecountpath)
    errorline = "A09:2021 - Secure Logging and Monitoring Failures"
    acceptedline = "Secure Logging and Monitoring Detected"
    if not my_file.is_file():
        with open (linecountpath, "w") as lc:
            lc.write("0")
    tanggal = date.today()
    from_line = 0
    with open(linecountpath, "r") as f :
        from_line = int(f.readline())

    if isfile(filepath1):
        linecount(filepath1, linecountpath)
        parsing_terminal(filepath1, from_line)
        add_data_log_failure(tanggal, acceptedline,filepath1)
    else:
        print(errorline)
        add_data_log_failure(tanggal, errorline, filepath1)