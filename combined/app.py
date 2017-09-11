from flask import Flask, redirect, render_template, json, request, jsonify, url_for
from flaskext.mysql import MySQL
from forms import SearchForm
from werkzeug import secure_filename #generate_password_hash, check_password_hash, 
import os
import sys
import pandas as pd
from sqlalchemy import create_engine
  
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
                evidence_name = request.form['evidence']
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
        return render_template('upload.html')

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
                _evidence = request.form['evidence']
                return redirect(url_for('result', query=_query, evidence = _evidence))
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
  # parse data 
    #print data
    conn = mysql.connect()
    cursor = conn.cursor()
    args = (query, evidence)
    cursor.callproc('searchOneEvidence', args)
    data = cursor.fetchall()
    conn.close()

    print data
    print type(data)
    datadf = pd.DataFrame(list(data), columns=['Name', 'Score'])
    datadf.set_index(['Name'],inplace = True)
    datadf.index.name = None
    print datadf
    data_table = datadf.to_html()
    titles = ['na']
    titles.append('Drugs with evidence '+ evidence)

    if len(data) >0:
    # no url change now
        return render_template('result.html',tables=[datadf.to_html(classes='male')], titles = titles)
    else:
        return render_template('error.html', error = 'No result!')
    
#@app.route('/showSignUp')
#def showSignUp():
#    return render_template('signup.html')


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
