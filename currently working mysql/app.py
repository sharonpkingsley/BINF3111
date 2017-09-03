from flask import Flask, render_template, json, request, jsonify
from flaskext.mysql import MySQL
from werkzeug import generate_password_hash, check_password_hash
   

mysql = MySQL()
app = Flask(__name__)

# MySQL configurations
app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = 'Sharon0108'
app.config['MYSQL_DATABASE_DB'] = 'drugdb'
app.config['MYSQL_DATABASE_HOST'] = '127.0.0.1'
mysql.init_app(app)


@app.route('/')
def main():
    return render_template('index.html')    

@app.route("/Search")
def Search():
    #_ = request.form['search']
    #search = request.args.get('Search')
    #password = request.args.get('Password')
    cursor = mysql.connect().cursor()
    cursor.execute("SELECT * from drugdb.1")
    return jsonify(data=cursor.fetchall())
    #data = cursor.fetchall()
    #return data
    #for row in data:
    #    print(row)
    if data is None:
     return "Username or Password is wrong"
    else:
     return "Logged in successfully"

@app.route('/showSignUp')
def showSignUp():
    return render_template('signup.html')


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

if __name__ == "__main__":
    app.run(port=5002)
