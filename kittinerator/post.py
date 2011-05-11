#!/usr/bin/python
# Filename: post.py
import logging
from google.appengine.ext import db
from google.appengine.api import images

class Post(db.Model):
    author = db.StringProperty(multiline=True)
    caption = db.TextProperty()
    content = db.TextProperty()
    date = db.DateTimeProperty(auto_now_add=True)
    images = db.ListProperty(db.Link)
    videos = db.ListProperty(db.Text)
    attachments = db.ListProperty(db.Blob)
      
# End of post.py