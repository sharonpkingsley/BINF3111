from flask import render_template, flash, redirect
from app import app
from .forms import SearchForm


@app.route('/', methods =['GET', 'POST'])
@app.route('/index', methods=['GET', 'POST'])
def index():
    form = SearchForm()
    if form.validate_on_submit():
        flash('Search requested for keyword="%s"' %
              (form.keyword.data))
        return redirect('/result')
    return render_template('index.html',
                           title='Search',
                           form=form)

@app.route('/result')
def result():
  return render_template('result.html', title='Result')