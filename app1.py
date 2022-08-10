from flask import Flask, render_template, redirect, url_for
from genericpath import isfile
import mariadb
import sys
import mysql.connector as database
from itertools import islice
import os
from pathlib import Path
from datetime import date
import time

import database_api1

#from turbo_flask import Turbo

#turbo = Turbo()
#app = Flask(__name__, static_folder='data')

app = Flask(__name__, static_folder="data")

#turbo.init_app(app)

	
@app.route("/terminal")
def tabel_in():
	data = database_api1.main_terminal()
	return render_template("index_out.html", my_list=data)

@app.route("/mariadb")
def tabel_out():
	data = database_api1.main_mariadb()
	return render_template("index_out.html", my_list=data)

@app.route("/firebase")
def gerbang_in():
	data = database_api1.main_firebase()
	return render_template("index_out.html", my_list=data)

	
if __name__ == "__main__":
	app.jinja_env.auto_reload = True
	app.config['TEMPLATES_AUTO_RELOAD'] = True
	app.run(debug = True, host='0.0.0.0',port=5000)
