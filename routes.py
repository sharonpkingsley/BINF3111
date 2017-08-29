from flask import Flask, redirect, render_template, request, url_for
from server import app, user_input
@app.route("/", methods=["GET", "POST"])
def index():
    user = {'nickname': 'Miguel'}  # fake user
    posts = [  # fake array of posts
        { 
            'author': {'nickname': 'John'}, 
            'body': 'Beautiful day in Portland!' 
        },
        { 
            'author': {'nickname': 'Susan'}, 
            'body': 'The Avengers movie was so cool!' 
        }
    ]
    return render_template("index.html",
                           title='Home',
                           user=user,
                           posts=posts)

@app.route("/Hello")
def hello():
    name = user_input[0][0]
    id=user_input[0][1]
    desc=user_input[0][2]
    return render_template("hello.html", name=name, id=id, desc=desc)