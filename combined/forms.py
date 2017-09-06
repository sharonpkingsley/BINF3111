from flask_wtf import FlaskForm
from wtforms import StringField, BooleanField
from wtforms.validators import DataRequired


class SearchForm(FlaskForm):
    query = StringField('keyword', validators=[DataRequired()])
    evidence = StringField('evidence', validators=[DataRequired()])
    evi1 = BooleanField('evi1', default=False)
    evi2 = BooleanField('evi2', default=False)
