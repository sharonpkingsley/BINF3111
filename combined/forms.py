from flask_wtf import FlaskForm
from wtforms import StringField, BooleanField, widgets, FloatField
from wtforms.validators import DataRequired

class SearchForm(FlaskForm):
    query = StringField('keyword', validators=[DataRequired()], render_kw={"class": "form-control"})
    evidence = StringField('evidence', validators=[DataRequired()])
    checkall = BooleanField('all')
    target = BooleanField('target')
    pathway = BooleanField('pathway')
    chemical_structure = BooleanField('chemical_structure')
    threshold = FloatField('threshold', default = 0, render_kw={"placeholder": "0"})
    