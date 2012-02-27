import os
from google.appengine.dist import use_library
os.environ['DJANGO_SETTINGS_MODULE'] = 'settings'
use_library('django', '1.2')

import cgi
import logging
import operator

from django.core.paginator import Page, Paginator, EmptyPage, PageNotAnInteger
from google.appengine.ext import db
from google.appengine.ext.webapp import template
from google.appengine.api import users
from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext import db

from post import Post

class GAEPaginator(Paginator):
    def page(self, number):
      "Returns a Page object for the given 1-based page number."
      number = self.validate_number(number)
      offset = (number - 1) * self.per_page
      if offset+self.per_page + self.orphans >= self.count:
        top = self.count
      return Page(self.object_list.fetch(self.per_page, offset), number, self)
      
class MainPage(webapp.RequestHandler):
    """
    Create and populate main page.
    """
    def get(self):
        posts_query = Post.all().order('-date')
        paginator = GAEPaginator(posts_query, 100)
        
        page = self.request.GET.get('page', 1)
        try:
            posts = paginator.page(page)
        except PageNotAnInteger:
            # If page is not an integer, deliver first page.
            posts = paginator.page(1)
        except EmptyPage:
            # If page is out of range (e.g. 9999), deliver last page of results.
            posts = paginator.page(paginator.num_pages)
        
        visible_posts = posts.object_list
        columns = [[], [], []]
        
        # TODO: calculate contributor ranking fer reals
        contributors = {}
        for i in range(len(visible_posts)):
            columns[i % len(columns)].append(visible_posts[i])
            if not visible_posts[i].author:
                continue
            if visible_posts[i].author in contributors:
                contributors[visible_posts[i].author] += 1
            else:
                contributors[visible_posts[i].author] = 1
        
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
            'columns': columns,
            'url': url,
            'url_linktext': url_linktext,
            'posts': posts,
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
        bot_test = self.request.get('bot_test').strip().lower()
        if (bot_test != 'orange'):
            self.redirect('/')
            return
             
        post = Post()

        if users.get_current_user():
            post.author = users.get_current_user().nickname()

        url = self.request.get('url').strip()
        if url:
            if not url.startswith("http"):
                url = "http://"+url
        post.images = [db.Link(url)]
        post.caption = self.request.get('caption')
        post.source = "homepage"
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