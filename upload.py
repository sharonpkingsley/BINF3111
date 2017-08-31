#!flask/bin/python
from flask import request
import os
from flask import Flask, request, redirect, url_for
from werkzeug import secure_filename
import sys
import pandas as pd
from sqlalchemy import create_engine
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

UPLOAD_FOLDER = '/Users/Vivian/downloads/uploads'
ALLOWED_EXTENSIONS = set(['csv'])

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
@app.route('/upload', methods=['GET', 'POST'])

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS

@app.route('/', methods=['GET', 'POST'])
def upload_file():
    if request.method == 'POST':
        file = request.files['file']
        if file and allowed_file(file.filename):
            filename = secure_filename(file.filename)
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            #file.save(secure_filename(file.filename))
            #df = pd.read_csv(file.filename)
            #print df
            #engine = create_engine('postgresql://Vivian:password@localhost/Druggg', echo=True)
            #return redirect(url_for('another_page',
            #                        filename=filename))
            return 'file uploaded successfully'
    return '''
    <!doctype html>
    <title>Upload new File</title>
    <h1>Upload new Drug Database File</h1>
    <form action="" method=post enctype=multipart/form-data>
      <p><input type=file name=file>
         <input type=submit value=Upload>
    </form>'''

@app.route('/uploads/')    
def another_page():    
	return 'file uploaded successfully'
    #table = pd.DataFrame.from_csv("test.csv")
    #return render_template("show_table.html", data=table.to_html())
