from flask import Flask

app = Flask(__name__)

@app.route("/firebase")
def firebase_call():
  import firebase.slice_firebase_version
  import firebase.snortparser_firebase
  
@app.route("/mariadb")
def mariadb_call():
  import MariaDB.slice
  import MariaDB.snortparser
  
@app.route("/terminal")
def terminal_call():
  import databaseterminal
  import database_terminal_firebase
