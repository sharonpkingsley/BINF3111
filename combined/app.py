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
app.config['PATHWAY_TO_DBCODE_FOLDER'] = '/users/apple/desktop/desktop/binf3111/combined/db_codes/'
app.config['PATHWAY_TO_MYSQL'] = '/usr/local/mysql-5.7.19-macos10.12-x86_64/bin/mysql'
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
evi_list = ['target', 'pathway', 'chemical_structure']

# file format check 
def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS

#load procedures
def load_sql_file(filename):
    f = open(app.config['PATHWAY_TO_DBCODE_FOLDER']+filename, 'r')
    proc = subprocess.Popen([app.config['PATHWAY_TO_MYSQL'], "--user=%s" % app.config['MYSQL_DATABASE_USER'], "--password=%s" % app.config['MYSQL_DATABASE_PASSWORD'], app.config['MYSQL_DATABASE_DB']],
                        stdin=f)
    out, err = proc.communicate()

#init function
def init():
    # create database
    engine = create_engine('mysql://' + app.config['MYSQL_DATABASE_USER'] + ':' + app.config['MYSQL_DATABASE_PASSWORD'] + '@' + app.config['MYSQL_DATABASE_HOST'], echo=True)
    engine.execute("CREATE DATABASE IF NOT EXISTS " + app.config['MYSQL_DATABASE_DB'])
    # load sql files
    load_sql_file('dropTables.sql')
    load_sql_file('add.sql')
    load_sql_file('edit.sql')
    load_sql_file('search.sql')
    # executable shell
    os.system('chmod +x cutFile.sh')
                            

# upload page
@app.route('/upload', methods=['GET', 'POST'])
def upload_file():
    type_list = [ evi_list[0], evi_list[1], evi_list[2], 'info']
    if request.method == 'POST':
        try:
            # init databases
            engine = create_engine('mysql://' + app.config['MYSQL_DATABASE_USER'] + ':' + app.config['MYSQL_DATABASE_PASSWORD'] + '@' + app.config['MYSQL_DATABASE_HOST'] + '/' + app.config['MYSQL_DATABASE_DB'], echo=True)
            
            if request.form['button'] == 'file':  
                file = request.files['file']
                evidence_name = request.form['option']
                            
                if file and allowed_file(file.filename):
                    filename = secure_filename(file.filename)
                    saveLocation = app.config['UPLOAD_FOLDER'] + filename
                    file.save(saveLocation)
                    if evidence_name == 'info' or evidence_name == 'links':
                        df1 = pd.read_csv(saveLocation)
                        df1.to_sql(evidence_name, con=engine, if_exists='replace')

                    else:
                        
                        chunks = pd.read_csv(saveLocation, chunksize=10000)
                        total_num_of_columns = 0
                        for chunk in chunks:
                            total_num_of_columns = len(chunk.columns)

                        #minus the first column, which is the name column
                        print total_num_of_columns
                        
                        # divide columns
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
                        print colRangeAll

                        # drop all existing related tables
                        conn = mysql.connect()
                        cursor = conn.cursor()
                        args = (evidence_name,)
                        cursor.callproc('deleteTables', args)
                        conn.close()

                        # read files
                        for j in range(0,num_of_tables):
                            columnRange = "1,"+colRangeAll[j]
                            file_name = str(UPLOAD_FOLDER) + "/" + str(evidence_name) + str(j) +".csv"
                            output_file = file_name.replace(" ", "")
                            subprocess.call(['./cutFile.sh', columnRange, str(saveLocation), output_file])
                            dff = pd.read_csv(output_file)
                            evidenceTable = str(evidence_name) + str(j)
                            evidenceTableName = evidenceTable.replace(" ", "")
                            dff.to_sql(evidenceTableName, con=engine, if_exists='replace')
                    message='Upload success'
                else: 
                    return render_template('error.html', error = e)
            elif request.form['button'] == 'new_drug':
                    print 'new_drug'
                    drugid = request.form['drugid']
                    drugname = request.form['drugname']
                    file = request.files['filenew']
                    evidence_name = request.form['option-new']
                    
                    #upload file to database 
                    if file and allowed_file(file.filename):
                        filename = secure_filename(file.filename)
                        saveLocation = app.config['UPLOAD_FOLDER'] + filename
                        file.save(saveLocation)
                        
                        df1 = pd.read_csv(saveLocation)
                        df1.to_sql(drugid, con=engine, if_exists='replace')
                    else: 
                        return render_template('error.html', error = e)  

                    #insert into tables
                    conn = mysql.connect()
                    cursor = conn.cursor()
                    args = (drugid, drugname, evidence_name)
                    cursor.callproc('newDrugAddition', args)
                    conn.commit()
                    conn.close()
                    message='New drug addtion success'
            elif request.form['button'] == 'update_drug':
                print 'edit'
                druga = request.form['druga']
                drugb = request.form['drugb']
                score = request.form['score']
                evidence_name = request.form['option-edit']
                druga = druga.split(' ')
                drugb = drugb.split(' ')
                
                #database connection
                conn = mysql.connect()
                cursor = conn.cursor()
                args = (druga[0], drugb[0], evidence_name, score)
                cursor.callproc('changeDrugRecord', args)
                conn.commit()
                conn.close()
                message='Score change success'     
            else:
                print 'else'
                message='Unknown operation'
            os.system('rm uploads/*')
            return render_template('upload_success.html', message=message)
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
  try:
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
        ## table result ##
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
        

        ##network result##

        nodes= []
        querynode = query
        for row in datadf.itertuples(index = True, name = 'Pandas'):
            nodes.extend([getattr(row,'Index')])
        json_nodes = json.dumps(nodes)

        conn.close()

        if len(data) >0:
            return render_template('result.html',tables=[datadf.to_html(classes='table')], titles = titles, querynode=querynode, nodes=json_nodes)
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
  except Exception as e:
        return render_template('error.html', error=e)  

# network view
@app.route('/cytoscape1.js')
def script():
    return render_template('cytoscape1.js')    

# autocomplete in search bar
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
    sql=("select CONCAT('\tDrugBank: ', IFNULL(links.DrugBank, ''), '\n\tKEGG: ', IFNULL(links.KEGG, ''), '\n\tPubChem: ', IFNULL(links.PubChem, ''), '\n\tDrugs.com: ', IFNULL(links.`Drugs.com`,'')) as hyperlink from  links, info where links.`GENERIC NAME` = info.`GENERIC NAME` and ID='" + search + "'")

    cursor.execute(sql)
    symbols = cursor.fetchall()
    results = [mv[0] for mv in symbols]
    
    cursor.close()
    conn.close()

    return jsonify(matching_results=results)


@app.route('/help', methods=['GET'])
def help():
    return render_template('help.html')         


if __name__ == '__main__':
    init()
    app.run(debug=True)
