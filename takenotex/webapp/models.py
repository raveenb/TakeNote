from django.db import models

from django.contrib.auth.models import User

from django.utils.timezone import now

# Create your models here.
class Lecture(models.Model):
    user = models.ForeignKey(User)
    name = models.CharField(max_length = 200, default = "", null = True)
    date = models.DateField(auto_now = True, default = now())
    done = models.BooleanField(default = False)

    def __unicode__(self):
        return self.name + ' - ' + str(self.date)

class InputImage(models.Model):
    user = models.ForeignKey(User)
    lecture = models.ForeignKey(Lecture, default = None, null = True)
    path = models.CharField(max_length = 200, default = "", null = True)
    url = models.URLField(max_length = 200, default = "", null = True)
    date = models.DateField(auto_now = True, default = now())

    def __unicode__(self):
        return  self.path + ' - ' + str(self.date)

