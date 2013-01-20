from django.db import models

from django.contrib.auth.models import User

class DropboxExtra(models.Model):
    user = models.OneToOneField(User,related_name="django_dropbox")
    dropbox_token = models.CharField(max_length=256, default = "", null = True)

class UserProfile(models.Model):
    user = models.OneToOneField(User)
    oauth_token = models.CharField(max_length = 200, default = "", null = True)
    oauth_secret = models.CharField(max_length = 200, default = "", null = True)
    cursor = models.CharField(max_length = 200, default = None, null = True)

    def __unicode__(self):
        return  self.user.first_name + ' ' + self.user.last_name

