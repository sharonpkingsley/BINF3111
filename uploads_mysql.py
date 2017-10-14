#!flask/bin/python
from flask import request
import os
from flask import Flask, request, redirect, url_for
from werkzeug import secure_filename
import sys
import pandas as pd
from sqlalchemy import create_engine
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import tempfile
import os



import subprocess
import shlex

UPLOAD_FOLDER = '/Users/Vivian/downloads/uploads'
ALLOWED_EXTENSIONS = set(['csv'])

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 10000 * 1024 * 1024
@app.route('/upload', methods=['GET', 'POST'])


def allowed_file(filename):
	return '.' in filename and \
		   filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS

@app.route('/', methods=['GET', 'POST'])
def upload_file():
	if request.method == 'POST':
		file = request.files['file']
		evidence_name = request.form['text']

		if file and allowed_file(file.filename):
			filename = secure_filename(file.filename)
			file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
			
			chunks = pd.read_csv(filename, chunksize=10000)
			total_num_of_columns = 0
			for chunk in chunks:
				total_num_of_columns = len(chunk.columns)

			#minus the first column, which is the name column
			total_num_of_columns = total_num_of_columns -1
			print total_num_of_columns
			additionRange = 0
			for i in range(0,15):
				if (total_num_of_columns%15 != 0):
					additionRange = total_num_of_columns/15 +1
				else:
					additionRange = total_num_of_columns/15

			x = 2
			startX = 2 #always
			print total_num_of_columns
			colRangeAll = []
			while (x + additionRange <= total_num_of_columns):
				x = x + additionRange
				#print startX, "-", x
				output = str(startX) + "-" + str(x)
				resultIn = output.replace(" ","")
				colRangeAll.append(resultIn)
				startX = x + 1
			if (x != total_num_of_columns):	
				output = str(startX) + "-" + str(total_num_of_columns)
				resultIn = output.replace(" ","")
				colRangeAll.append(resultIn)
			#start from 0..14
			print colRangeAll


			for j in range(0,15):
				columnRange = "1,"+colRangeAll[j]
				file_name = str(UPLOAD_FOLDER) + "/" + str(evidence_name) + str(j) +".csv"
				output_file = file_name.replace(" ", "")
				subprocess.call(['./cutFile.sh', columnRange, str(filename), output_file])
				dff = pd.read_csv(output_file)
				engine = create_engine('mysql://root:1234@localhost/drugdb', echo=True)
				evidenceTable = str(evidence_name) + str(j)
				evidenceTableName = evidenceTable.replace(" ", "")
				dff.to_sql(evidenceTableName, con=engine, if_exists='replace')

				#chunk.to_sql(evidence_name, con=engine, if_exists='append')
			#engine1 = create_engine('mysql://root:1234@localhost', echo=True)
			#engine1.execute("CREATE DATABASE IF NOT EXISTS drugdb")
			#engine = create_engine('mysql://root:1234@localhost/drugdb', echo=True)
			#engine = create_engine('mysql://root:1234@localhost/myDrugDatabase', echo=True)
			#df1.to_sql(evidence_name, con=engine, if_exists='replace')
			
			return 'file uploaded successfully'
	return '''
	<!doctype html>
	<title>Upload new File</title>
	<h1>Upload new Drug Database File</h1>
	<form action="" method=post enctype=multipart/form-data>
	  <p><input type=file name=file>
		 <input type="text" name="text"/>
		 <input type=submit value=Upload>
	</form>'''
