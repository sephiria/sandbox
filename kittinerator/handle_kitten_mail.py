import logging
from email.header import decode_header
from google.appengine.ext import webapp
from google.appengine.ext.webapp.mail_handlers import InboundMailHandler
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext import db
from lib.BeautifulSoup import BeautifulSoup
from post import Post

class MailHandler(InboundMailHandler):
    """
    Handle incoming mail for image links, video links, image attachments, etc.
    """
    def receive(self, message):
        post = Post()
        html_bodies = message.bodies('text/html')
        img_links = []
        video_links = []
        for content_type, body in html_bodies:
            decoded_body = body.decode()
            img_links.extend(self.find_image_links(decoded_body))
            video_links.extend(self.find_video_links(decoded_body))
    
        if hasattr(message, "attachments") and message.attachments:
            post.attachments = []
            for attachment in message.attachments:
                post.attachments.append(db.Blob(attachment[1].decode()))
    
        plaintext_bodies = message.bodies('text/plain')
        allBodies = '';
        for body in plaintext_bodies:
            allBodies = allBodies + body[1].decode()
    
        if hasattr(message, "subject"):
            subject, encoding = decode_header(message.subject)[0]
            post.caption = unicode(subject)
        post.author = message.sender
        post.content = allBodies
        post.images = img_links
        post.videos = video_links
        post.source = "email"
        post.put()
  
    def find_image_links(self, html_message):
        soup = BeautifulSoup(html_message)
        images = soup('img')
        links = []
        for img in images:
            links.append(db.Link(img['src']))
        return links
  
    def find_video_links(self, html_message):
        soup = BeautifulSoup(html_message)
        embeds = soup('embed')
        tags = []
        for video in embeds:
            tags.append(db.Text(str(video)))
        return tags

application = webapp.WSGIApplication([MailHandler.mapping()], debug=True)

def main():
    run_wsgi_app(application)

if __name__ == "__main__":
    main()