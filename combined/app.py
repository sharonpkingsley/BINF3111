from flask import Flask, redirect, render_template, json, request, jsonify, url_for
from flaskext.mysql import MySQL
from forms import SearchForm
from werkzeug import secure_filename #generate_password_hash, check_password_hash, 
import os
import sys
import re
import pandas as pd
import StringIO, csv 
from sqlalchemy import create_engine

from flask import send_file
from flask import make_response  
#mysql setup
mysql = MySQL()
app = Flask(__name__)

# MySQL configurations
app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = 'binf3111'
app.config['MYSQL_DATABASE_DB'] = 'drugdb'
app.config['MYSQL_DATABASE_HOST'] = 'localhost'
mysql.init_app(app)

# upload configs
UPLOAD_FOLDER = 'uploads/'
ALLOWED_EXTENSIONS = set(['csv'])

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# form validate configs
app.config['CSRF_ENABLED'] = True
app.config['SECRET_KEY'] = 'you-will-never-guess'

# file format check ########TO DO#######
def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS

# upload page
@app.route('/upload', methods=['GET', 'POST'])
def upload_file():
    if request.method == 'POST':
        try:
                file = request.files['file']
                evidence_name = request.form['option']
                if file and allowed_file(file.filename):
                    filename = secure_filename(file.filename)
                    saveLocation = app.config['UPLOAD_FOLDER'] + filename
                    file.save(saveLocation)
            #file.save(filepath)
            #token = store_in_db(filepath)
            #return redirect(url_for('read_uploaded_file',
            #                        filename=filename))
                    df1 = pd.read_csv(saveLocation)
                    engine = create_engine('mysql://root:binf3111@localhost/drugdb', echo=True)
                    df1.to_sql(evidence_name, con=engine, if_exists='replace')
                    return render_template('upload_success.html')
        except Exception as e:
            return render_template('error.html', error = 'No file selected or no evidence entered!')
    else:
        return render_template('upload.html', evidence_list = ['evia', 'evib'])

# main page
@app.route('/', methods=['GET', 'POST'])
def main():
    return render_template('index.html')

# search page
@app.route("/search", methods=['GET', 'POST'])
def search():
    if request.method == 'POST':
       try:
                _query = request.form['query']
                #get list
                evi_list = ['evia', 'evib']
                chosen_evis = []
                for evi in evi_list:
                    try:
                        if request.form[str(evi)] == 'y':
                            chosen_evis.append(evi)
                    except Exception as e:
                        print 'skip' + evi
                #print chosen_evis
                return redirect(url_for('result', query=_query, evidence = chosen_evis))
       except Exception as e:
                return render_template('error.html', error= 'Drug or evidence name is missing.')
       
       
    else:
        form = SearchForm()
        #if form.validate_on_submit():
        #    flash('Search requested for query="%s"' %
        #          (form.query.data))
        #    return redirect(url_for('result', query=form.query.data), evidence=form.evidence.data)
        return render_template('search.html',
                               title='Search',
                               form=form)


# result page
@app.route('/result/<query>/<evidence>', methods=['GET','POST'])
def result(query,evidence):
    # format unicode into string - correct format to input into database
    formatted_evidence = str(evidence).replace("[",'')
    formatted_evidence = formatted_evidence.replace(']','')
    formatted_evidence = formatted_evidence.replace("'",'')
    formatted_evidence = formatted_evidence.replace(" ",'')
    print formatted_evidence
    evidences = formatted_evidence.split(",")
        
    if request.method == 'GET':
        # DATA RETRIEVATION
        conn = mysql.connect()
        cursor = conn.cursor()
        datadf_htmls = []
        titles = ['na']
        for evi in evidences:
            print evi
            args = (query, evi)
            cursor.callproc('searchOneEvidence', args)
    
            data = cursor.fetchall()
            datadf = pd.DataFrame(list(data), columns=['Name', 'Score'])
            datadf.set_index(['Name'],inplace = True)
            datadf.index.name = None
            print datadf
            data_table = datadf.to_html()
            titles.append('Drugs with evidence '+ evi)
            datadf_htmls.append(datadf.to_html(classes='male'))
            print titles
    
        conn.close()
        #print data
        #print type(data)
        #datadf = pd.DataFrame(list(data), columns=['Name', 'Score'])
        #datadf.set_index(['Name'],inplace = True)
        #datadf.index.name = None
        #print datadf
        #data_table = datadf.to_html()
        #titles = ['na']
        #titles.append('Drugs with evidence '+ evidence)

        if len(data) >0:
        # no url change now
            return render_template('result.html',tables=datadf_htmls, titles = titles)
        else:
            return render_template('error.html', error = 'No result!')
    elif request.method == 'POST':
        if request.form['submit'] == 'Get Data':
            #query = request.form['drug']
            #evidence_input_name = get_evis()
            #print drug_input_name
            #print evidence_input_name
            print evidences
            print query
            conn = mysql.connect()
            cursor = conn.cursor()
            si = StringIO.StringIO()
            cw = csv.writer(si)
            for evi in evidences:
                print evi
                args = (query, evi)
                cursor.callproc('searchOneEvidence', args)
                data = cursor.fetchall()

                cw.writerow([i[0] for i in cursor.description])
                cw.writerows(data)
                response = make_response(si.getvalue())
                response.headers['Content-Disposition'] = 'attachment; filename=report.csv'
                response.headers["Content-type"] = "text/csv"
            conn.close()
            return response
        

@app.route('/cytoscape1.js')
def script():
    return render_template('cytoscape1.js')    

NAMES=["abc","abcd","abcde","abcdef"]

@app.route('/autocomplete',methods=['GET'])
def autocomplete():
    search = request.args.get('query')

    app.logger.debug(search)
    return jsonify(json_list=NAMES) 

# get evidence list
def get_evis():
    evi_list = ['evia', 'evib']
    chosen_evis = []
    for evi in evi_list:
            try:
                if request.form[str(evi)] == 'y':
                    chosen_evis.append(evi)
            except Exception as e:
                print 'skip' + evi
    return chosen_evis


#export the data
@app.route('/export', methods=['GET','POST'])   
def export():
    if request.method == 'POST':
        if request.form['submit'] == 'Get Data':
            drug_input_name = request.form['drug']
            evidence_input_name = get_evis()
            print drug_input_name
            print evidence_input_name

            conn = mysql.connect()
            cursor = conn.cursor()
            si = StringIO.StringIO()
            cw = csv.writer(si)

            args = (drug_input_name, evidence_input_name)
            cursor.callproc('searchOneEvidence', args)
            data = cursor.fetchall()

            cw.writerow([i[0] for i in cursor.description])
            cw.writerows(data)
            response = make_response(si.getvalue())
            response.headers['Content-Disposition'] = 'attachment; filename=report.csv'
            response.headers["Content-type"] = "text/csv"
            conn.close()
            return response
           


@app.route('/signUp',methods=['POST','GET'])
def signUp():
    try:
        _ = request.form['search']
        _email = request.form['inputEmail']
        _password = request.form['inputPassword']

        # validate the received values
        if _name and _email and _password:
            
            # All Good, let's call MySQL
            
            cursor = mysql.connect().cursor()
            cursor.execute("SELECT * from drugdb.2")
            return jsonify(data=cursor.fetchall())           

            #cursor.execute("SELECT * from 1;")
            #data = cursor.fetchall()
            return data
            
            for row in data:
                print(row)
            #_hashed_password = generate_password_hash(_password)
            #cursor.callproc('sp_createUser',(_name,_email,_hashed_password))
            #data = cursor.fetchall()

            #if len(data) is 0:
            #    conn.commit()
             #   return json.dumps({'message':'User created successfully !'})
            #else:
            #    return json.dumps({'error':str(data[0])})
        #else:
         #   return json.dumps({'html':'<span>Enter the required fields</span>'})

    except Exception as e:
        return json.dumps({'error':str(e)})
    finally:
        cursor.close() 
        conn.close()

if __name__ == '__main__':
    app.run(debug=True)
