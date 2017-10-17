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

import subprocess
import shlex

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
app.config['MAX_CONTENT_LENGTH'] = 10000 * 1024 * 1024

# form validate configs
app.config['CSRF_ENABLED'] = True
app.config['SECRET_KEY'] = 'you-will-never-guess'

#evidence list
evi_list = ['target', 'struct', 'chem']

# file format check ########TO DO#######
def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS

# upload page
@app.route('/upload', methods=['GET', 'POST'])
def upload_file():
    type_list = [ evi_list[0], evi_list[1], evi_list[2], 'info']
    if request.method == 'POST':
        try:
            if request.form['button'] == 'file':  
                file = request.files['file']
                evidence_name = request.form['option']
                if file and allowed_file(file.filename):
                    filename = secure_filename(file.filename)
                    saveLocation = app.config['UPLOAD_FOLDER'] + filename
                    file.save(saveLocation)
                    if evidence_name == 'info':
                        df1 = pd.read_csv(saveLocation)
                        engine1 = create_engine('mysql://root:binf3111@localhost', echo=True)
                        engine1.execute("CREATE DATABASE IF NOT EXISTS drugdb")
                        engine = create_engine('mysql://root:binf3111@localhost/drugdb', echo=True)
                        df1.to_sql(evidence_name, con=engine, if_exists='replace')

                    else:
                        
                        chunks = pd.read_csv(saveLocation, chunksize=10000)
                        total_num_of_columns = 0
                        for chunk in chunks:
                            total_num_of_columns = len(chunk.columns)

                        #minus the first column, which is the name column
                        print total_num_of_columns
                        
                        x = 2
                        startX = 2 #always
                        print total_num_of_columns
                        colRangeAll = []
                        num_of_tables = 0
                        while (x + 200 <= total_num_of_columns):
                            x = x + 200
                            #print startX, "-", x
                            output = str(startX) + "-" + str(x)
                            resultIn = output.replace(" ","")
                            colRangeAll.append(resultIn)
                            startX = x + 1
                            num_of_tables += 1
                        if (x != total_num_of_columns): 
                            output = str(startX) + "-" + str(total_num_of_columns)
                            resultIn = output.replace(" ","")
                            colRangeAll.append(resultIn)
                            num_of_tables += 1
                        #start from 0..14
                        print colRangeAll


                        for j in range(0,num_of_tables):
                            columnRange = "1,"+colRangeAll[j]
                            file_name = str(UPLOAD_FOLDER) + "/" + str(evidence_name) + str(j) +".csv"
                            output_file = file_name.replace(" ", "")
                            os.system('chmod +x cutFile.sh')
                            subprocess.call(['./cutFile.sh', columnRange, str(saveLocation), output_file])
                            dff = pd.read_csv(output_file)
                            print 'yoki'
                            engine = create_engine('mysql://root:binf3111@localhost/drugdb', echo=True)
                            print 'joki'
                            evidenceTable = str(evidence_name) + str(j)
                            evidenceTableName = evidenceTable.replace(" ", "")
                            print '3check'
                            dff.to_sql(evidenceTableName, con=engine, if_exists='replace')
                            print '4check'
                return render_template('upload_success.html')
            elif request.form['button'] == 'new_drug':
                print 'pei!!!'
        except Exception as e:
            return render_template('error.html', error = e)

    else:
        return render_template('upload.html', evidence_list = evi_list, type_list=type_list)

# main page
@app.route('/', methods=['GET', 'POST'])
def main():
    return render_template('index.html')

# search page
@app.route("/search", methods=['GET', 'POST'])
def search():
    if request.method == 'POST':
       try:
                query = request.form['query']
                threshold = request.form['threshold']
                print threshold
                #get list
                chosen_evis = []
                for evi in evi_list:
                    try:
                        if request.form[str(evi)] == 'y':
                            chosen_evis.append(evi)
                    except Exception as e:
                        print 'skip' + evi
                #print chosen_evis
                if chosen_evis == []:
                    raise ValueError('No evidence selected!')
                print query, chosen_evis, threshold
                drugids = query.split(' ')
                drugid = drugids[0]
                print drugid
                return redirect(url_for('result', query=drugid, evidence = chosen_evis, threshold = threshold))
       except Exception as e:
                return render_template('error.html', error=e)
       
       
    else:
        form = SearchForm()
        return render_template('search.html',
                               title='Search',
                               form=form)


# result page
@app.route('/result/<query>/<evidence>/<threshold>', methods=['GET','POST'])
def result(query,evidence, threshold):
    # format unicode into string - correct format to input into database
    formatted_evidence = str(evidence).replace("[",'')
    formatted_evidence = formatted_evidence.replace(']','')
    formatted_evidence = formatted_evidence.replace("'",'')
    formatted_evidence = formatted_evidence.replace(" ",'')
    print formatted_evidence
    evidences = formatted_evidence.split(",")
    
    while len(evidences) < 3:
        evidences.append('')
    print evidences
    
    if request.method == 'GET':
        # DATA RETRIEVATION
        conn = mysql.connect()
        cursor = conn.cursor()
        titles = ['na']
        
        args =(query, evidences[0], evidences[1], evidences[2], float(threshold))
        print args
        cursor.callproc('searchMaxThreeSelectedEvidence', args)
        print 'here'
        data = cursor.fetchall()
        columns = ['ID','Name']
        for evi in evidences:
            if evi is not '':
                columns.append(evi)
        columns.append('Score')
        print columns


        datadf = pd.DataFrame(list(data), columns = columns)
        datadf.set_index(['ID'], inplace= True)
        datadf.index.name = None
        titles.append('Drugs with evidence ' + (', ').join(evidences))
        print datadf
        
        conn.close()
        
        if len(data) >0:
        # no url change now
            return render_template('result.html',tables=[datadf.to_html(classes='table')], titles = titles)
        else:
            return render_template('error.html', error = 'No result!')
    elif request.method == 'POST':
            print evidences
            print query
            conn = mysql.connect()
            cursor = conn.cursor()
            si = StringIO.StringIO()
            cw = csv.writer(si)
            args =(query, evidences[0], evidences[1], evidences[2], threshold)
            print args
            cursor.callproc('searchMaxThreeSelectedEvidence', args)
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

@app.route('/autocomplete',methods=['GET'])
def autocomplete():

    search = request.args.get('q')
    conn = mysql.connect()
    cursor = conn.cursor()
    sql=("select CONCAT(ID, ' ', `GENERIC NAME`) from  info where ID like '%"+search+"%' or `GENERIC NAME` like '%"+search+"%'")
    cursor.execute(sql)
    symbols = cursor.fetchall()
    results = [mv[0] for mv in symbols]
    
    cursor.close()
    conn.close()


    return jsonify(matching_results=results)

@app.route('/hyperlink',methods=['GET'])
def hyperlink():

    search = request.args.get('q')
    conn = mysql.connect()
    cursor = conn.cursor()
    sql=("select CONCAT(ID, ' ', `GENERIC NAME`) from  info where ID like '%"+search+"%' or `GENERIC NAME` like '%"+search+"%'")
    cursor.execute(sql)
    symbols = cursor.fetchall()
    results = [mv[0] for mv in symbols]
    
    cursor.close()
    conn.close()


    return jsonify(matching_results=results)


#export the data
@app.route('/export', methods=['GET','POST'])   
def export():
    if request.method == 'POST':
        #if request.form['submit'] == 'Get Data':
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
