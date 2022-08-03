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
linecountpath_rel = "linecountterminal_firebase.txt"
linecountpath = os.path.join(script_dir, rel_path)
import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
# Fetch the service account key JSON file contents
cred = credentials.Certificate('/Kode_TA_Ihsan/Firebase/ta-ihsan-firebase-adminsdk-dqlgz-233439b4b0.json')
# Initialize the app with a service account, granting admin privileges
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://ta-ihsan-default-rtdb.firebaseio.com/'
})

ref = db.reference('terminal_log')


def add_data(Tanggal, IsiLog):
    value = {
        "Tanggal" : str(Tanggal),
        "IsiLog" : IsiLog
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
            while end < len(line):
                end += 1
            Deskripsi = line[start:end]
            tgl = date.today()
            print(tgl, Deskripsi)
            add_data(tgl, Deskripsi)

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
