import os
from google.appengine.dist import use_library
os.environ['DJANGO_SETTINGS_MODULE'] = 'settings'
use_library('django', '1.2')

import cgi
import logging
import operator

from google.appengine.ext import db
from google.appengine.ext.webapp import template
from google.appengine.api import users
from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext import db

from post import Post

class MainPage(webapp.RequestHandler):
    """
    Create and populate main page.
    """
    def get(self):
        posts_query = Post.all().order('-date')
        all_posts = posts_query.fetch(100)
        columns = [[], [], []]
        
        # TODO: calculate contributor ranking fer reals
        contributors = {}
        for i in range(len(all_posts)):
            columns[i % len(columns)].append(all_posts[i])
            if not all_posts[i].author:
                continue
            if all_posts[i].author in contributors:
                contributors[all_posts[i].author] += 1
            else:
                contributors[all_posts[i].author] = 1
        
        sorted_contributors = sorted(contributors.iteritems(), key=operator.itemgetter(1))
        sorted_contributors.reverse()
        top_contributors = sorted_contributors[0:min(3, len(contributors))]
        
        if users.get_current_user():
            url = users.create_logout_url(self.request.uri)
            url_linktext = 'Logout'
        else:
            url = users.create_login_url(self.request.uri)
            url_linktext = 'Login'

        template_values = {
            'top_contributors': top_contributors,
            'posts': columns,
            'url': url,
            'url_linktext': url_linktext,
        }

        path = os.path.join(os.path.dirname(__file__), 'index.html')
        self.response.out.write(template.render(path, template_values))

class Image(webapp.RequestHandler):
    """
    Handle image requests.
    """
    def get(self):
        post = db.get(self.request.get("img_id"))
        if post.attachments:
            self.response.headers['Content-Type'] = "image/png"
            self.response.out.write(post.attachments[0])
        else:
            self.response.out.write("No image")
                    
class Posting(webapp.RequestHandler):
    """
    Handle posting of Posts.
    """
    def post(self):
        post = Post()

        if users.get_current_user():
            post.author = users.get_current_user().nickname()

        url = self.request.get('url').strip()
        if url:
            if not url.startswith("http"):
                url = "http://"+url
        post.images = [db.Link(url)]
        post.caption = self.request.get('caption')
        post.put()
        self.redirect('/')

application = webapp.WSGIApplication(
                                     [('/', MainPage),
                                     ('/img', Image),
                                      ('/sign', Posting)],
                                     debug=True)

def main():
    run_wsgi_app(application)

if __name__ == "__main__":
    main()