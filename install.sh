#!/bin/sh

#install flask
pip install flask
#install pandas
pip install pandas
#install flaskext.mysql
pip install flask-mysql
#install flask-wtforms
pip install Flask-WTF
#install sqlalchemy
pip install SQLAlchemy

#install mysql???????????????
$mysqlpass = binf3111
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password '$mysqlpass'"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password '$mysqlpass'"
export DEBIAN_FRONTEND=noninteractive
sudo -E apt-get install -y -q mysql-server libmysqlclient-dev


#connect mysql
mysql -u root -p
#change password
sudo grep 'binf3111' /var/log/mysqld.log
#run flask
export FLASK_APP=app.py
flask run
