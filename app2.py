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

import database_api_firebase, tesapi

#from turbo_flask import Turbo

#turbo = Turbo()
#app = Flask(__name__, static_folder='data')

app = Flask(__name__, static_folder="data")

#turbo.init_app(app)

	
@app.route("/terminal")
def terminal():
	data = database_api_firebase.main_terminal()
	return render_template("index_out.html", my_list=data)

@app.route("/snort")
def snort():
	data = database_api_firebase.main_snort()
	return render_template("index_out.html", my_list=data)

@app.route("/ejbca")
def ejbca():
	data = database_api_firebase.main_ejbca()
	return render_template("index_out.html", my_list=data)

@app.route("/tes")
def tes():
	example_embed='This string is from python'
	return render_template('index1.html', embed=example_embed)

if __name__ == "__main__":
	app.jinja_env.auto_reload = True
	app.config['TEMPLATES_AUTO_RELOAD'] = True
	app.run(debug = True, host='0.0.0.0',port=5000)
