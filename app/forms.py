from flask_wtf import Form
from wtforms import StringField, BooleanField
from wtforms.validators import DataRequired


class SearchForm(Form):
    keyword = StringField('keyword', validators=[DataRequired()])
    #remember_me = BooleanField('remember_me', default=False)
