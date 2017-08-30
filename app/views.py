from flask import render_template, flash, redirect
from app import app
from .forms import SearchForm


@app.route('/')
@app.route('/index')
def index():
    form = SearchForm()
    if form.validate_on_submit():
        flash('Search requested for keyword="%s"' %
              (form.keyword.data))
        return redirect('/index')
    return render_template('index.html',
                           title='Search',
                           form=form)

