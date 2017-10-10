from flask_wtf import FlaskForm
from wtforms import StringField, BooleanField, widgets, FloatField
from wtforms.validators import DataRequired

#class MultiCheckboxField(SelectMultipleField):
#    widget = widgets.ListWidget(html_tag=u'ul',prefix_label=False)
#    option_widget = widgets.CheckboxInput()

class SearchForm(FlaskForm):
    query = StringField('keyword', validators=[DataRequired()], render_kw={"class": "form-control"})
    evidence = StringField('evidence', validators=[DataRequired()])
    checkall = BooleanField('all')
    evidence1 = BooleanField('evidence1')
    evidence2 = BooleanField('evidence2')
    evidence3 = BooleanField('evidence3')
    threshold = FloatField('threshold', default = 0, render_kw={"placeholder": "0"})
    
#    evidences_list = [('evi1','evi1'), ('evi2','evi2'),('evi3','evi3')]

#    evidences = MultiCheckboxField('',choices = evidences_list)
    #evi1 = BooleanField('evi1', default=False)
    