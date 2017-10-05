from flask_wtf import FlaskForm
from wtforms import StringField, BooleanField, widgets, SelectMultipleField
from wtforms.validators import DataRequired

#class MultiCheckboxField(SelectMultipleField):
#    widget = widgets.ListWidget(html_tag=u'ul',prefix_label=False)
#    option_widget = widgets.CheckboxInput()

class SearchForm(FlaskForm):
    query = StringField('keyword', validators=[DataRequired()])
    evidence = StringField('evidence', validators=[DataRequired()])
    checkall = BooleanField('all')
    evia = BooleanField('evia')
    evib = BooleanField('evib')
    threshold = StringField('threshold', render_kw={"placeholder": "0"})
    
#    evidences_list = [('evi1','evi1'), ('evi2','evi2'),('evi3','evi3')]

#    evidences = MultiCheckboxField('',choices = evidences_list)
    #evi1 = BooleanField('evi1', default=False)
    