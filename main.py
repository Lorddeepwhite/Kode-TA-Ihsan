from flask import Flask
import sys
import os.path
from subprocess import call

d = os.path.dirname(os.path.realpath(__file__))
app = Flask(__name__)

@app.route("/firebase")
def firebase_call():
  call(["python3", f"{d}/Firebase/slice_firebase_version.py"])
  call(["python3", f"{d}/Firebase/snortparser_firebase.py"])

@app.route("/mariadb")
def MariaDB_call():
  call(["python3", f"{d}/MariaDB/slice.py"])
  call(["python3", f"{d}/MariaDB/snortparser.py"])

@app.route("/terminal")
def terminal_call():
  call(["python3", f"{d}/databaseterminal.py"])
  call(["python3", f"{d}/database_terminal_firebase.py"])
