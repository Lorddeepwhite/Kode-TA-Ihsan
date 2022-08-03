# Module Imports
from datetime import date
import mariadb
import sys
import mysql.connector as database


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
        statement = "INSERT INTO mytable (Tanggal, Timestamp, Log_Level, Event_Module, Server_Service_Thread_Port, Deskripsi_EventPaket_Input_Output) VALUES (%s, %s, %s, %s, %s, %s)"
        data = (Tanggal, Timestamp, Log_Level, Event_Module, Server_Service_Thread_Port, Deskripsi_EventPaket_Input_Output)
        cur.execute(statement, data)
        conn.commit()
        print("Successfully added entry to database")
    except database.Error as e:
        print(f"Error adding entry to database: {e}")

def parsing(filepath) :
    data = []
    with open(filepath, 'r') as infile:
        while (string := infile.readline().rstrip()):
            start = 0
            end = start

            while string[end] != " " :
                end += 1
                
            timestamp = string[start:end]
            start = end

            # space
            while string[start] == " " :
                start += 1
                
            end = start
            while string[end] != " " :
                end += 1
            level = string[start:end]

            start = end
            # space
            while string[start] == " " :
                start += 1
                
            # Bracketing
            end = start
            while string[end] != "]" :
                end += 1
            event_name = string[start+1:end]

            # Bracketing
            start = end

            while string[start] == "(" :
                start += 1
                
            end = start
            while string[end] != ")" :
                end += 1
            server_port = string[start+3:end]

            #Tab (masih terpotong string yang setelah ':')
            start = end
            while string[start] == " " :
                start += 1
            end = start
            while end < len(string):
                end += 1
            Deskripsi = string[start+2:end]
            tanggal = date.today()
            print((tanggal, timestamp, level, event_name, server_port, Deskripsi))
            add_data(tanggal, timestamp, level, event_name, server_port, Deskripsi)

parsing('/home/ihsanfr/Downloads/ejbca1.log')
