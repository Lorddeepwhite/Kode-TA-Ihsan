# Module Imports
import mariadb
import sys
import mysql.connector as database
from itertools import islice
import os
from pathlib import Path
from datetime import date
import schedule
import time

linecountpath = "/home/ihsanfr/Downloads/linecount.txt"
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

def add_data(Timestamp,  Event_Module):
    try:
        statement = "INSERT INTO mytable (Timestamp, Event_Module) VALUES (%s, %s)"
        data = (Timestamp,  Event_Module)
        cur.execute(statement, data)
        conn.commit()
        print("Successfully added entry to database")
    except database.Error as e:
        print(f"Error adding entry to database: {e}")

def parsing(filepath) :
    with open(filepath, 'r') as infile:
         while (line := infile.readline().rstrip()):
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
            print((tanggal, timestamp, level, event_name, server_port, Deskripsi))
            add_data(timestamp, event_name)

parsing('/home/ihsanfr/Downloads/ejbca1.log')