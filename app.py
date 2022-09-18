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

import database_api_firebase, callcurl

#from turbo_flask import Turbo

#turbo = Turbo()
#app = Flask(__name__, static_folder='data')

filepath1 = "/var/log/snort/alert"
filepath2 = "/home/ihsanfr/Kode_TA_Ihsan/ejbca1.log"
filepath4 = "/home/ihsanfr/Kode_TA_Ihsan/tes.log"

app = Flask(__name__, static_folder="data")

#turbo.init_app(app)

	
@app.route("/terminal")
def terminal():
	data = database_api_firebase.main_terminal(filepath4)
	return render_template("index1.html", my_list=data)

@app.route("/snort")
def snort():
	data = database_api_firebase.main_snort(filepath1)
	return render_template("index1.html", my_list=data)

@app.route("/ejbca")
def ejbca():
	data = database_api_firebase.main_ejbca(filepath2)
	return render_template("index1.html", my_list=data)

@app.route("/tes")
def tes():
	example_embed='This string is from python'
	return render_template('index1.html', embed=example_embed)

@app.route("/server")
def server(): 
	data = database_api_firebase.main_server()
	return render_template('index1.html', my_list=data)

@app.route("/callcurl")
def curl():
	data = callcurl.curl(filepath4)
	return render_template('index1.html', my_list=data)

@app.route("/main")
def main():
	data4 = callcurl.curl(filepath4)
	data1 = database_api_firebase.main_terminal(filepath4)
	data2 = database_api_firebase.main_snort(filepath1)
	data = database_api_firebase.main_ejbca(filepath2)
	data3 = database_api_firebase.main_server()
	return render_template("index1.html", my_list=(data1, data2, data, data3, data4))


if __name__ == "__main__":
	app.jinja_env.auto_reload = True
	app.config['TEMPLATES_AUTO_RELOAD'] = True
	app.run(debug = True, host='0.0.0.0',port=5000)
