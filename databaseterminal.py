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
linecountpath_rel = "linecountterminal.txt"
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

def add_data_terminal(Tanggal, IsiLog):
    try:
        statement = "INSERT INTO TerminalTable (Tanggal, IsiLog) VALUES (%s, %s)"
        data = (Tanggal, IsiLog)
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
            while end < len(line):
                end += 1
            Deskripsi = line[start:end]
            tanggal = date.today()
            print(tanggal, Deskripsi)
            add_data_terminal(tanggal, Deskripsi)

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
filepath1 = 'tes.log'

if isfile(filepath1):
    linecount(filepath1)
    parsing(filepath1, from_line)
else:
    print("A09:2021 - Secure Logging and Monitoring Failures")
