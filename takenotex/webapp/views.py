# Create your views here.
from django.contrib.auth.decorators import login_required
from django.shortcuts import render_to_response, redirect, render
from django.template import RequestContext
from django.views.decorators.csrf import csrf_exempt
from django.utils import dateparse, timezone

from sendgrid.message import SendGridEmailMessage

from django.core.mail import send_mail

import urllib2

import pprint

from models import InputImage, Lecture

def start(request):
    return render_to_response('start.html', RequestContext(request, locals()))

@login_required
def home(request):
    print 'webapp.views.home'
    lectures = find_lectures(request)
    for lecture in lectures:
        find_images(request, lecture)

    data = dict()
    lecture_list = list(Lecture.objects.filter(user = request.user).order_by('-date'))
    for lecture in lecture_list:
        data[lecture] = list(InputImage.objects.filter( user = request.user, 
                                                        lecture = lecture).order_by('-date'))
    pprint.pprint(data)

    return render_to_response('home.html', RequestContext(request, locals()))

@login_required
def capture(request):
    return render_to_response('capture.html', RequestContext(request, locals()))

@csrf_exempt
@login_required
def add_lecture(request):
    print 'webapp.views.add_lecture'
    if request.method == 'POST':
        lecture = Lecture(  user = request.user, 
                            name = '/Lecture_' + request.POST.get('name'),
                            done = False)
        lecture.save()
        return render_to_response('capture.html', RequestContext(request, locals()))
    else:
        return redirect('/')

@csrf_exempt
@login_required
def add_image(request):
    print 'webapp.views.add_image'
    # pprint.pprint(request) 
    if request.method == 'POST':
        try:
            lecture = Lecture.objects.get(user = request.user, id = request.POST.get('lecture'))
            name = str(timezone.now())
            i = InputImage( user = request.user, 
                            path = name,
                            lecture = lecture,
                            url = request.POST.get('file'))
            i.save()
            pprint.pprint(i)
            upld_image(request, i)
            # translate(i)            
        except Exception as e:
            print 'Exception: webapp.views.add_image - ' + str(e)
        # return render_to_response('capture.html', RequestContext(request, locals()))
    # else:
    return redirect('/home/')

def upld_image(request, image):
    print 'webapp.views.upld_image'
    try:
        pprint.pprint(request.session)
        if request.session.get('dropbox_client') is None:
            print 'Error: no client'
            return None
        # get the dropbox client
        client = request.session['dropbox_client']
        
        # open the url from filepicker
        f = urllib2.urlopen(image.url)
        
        # make the file name
        path = image.lecture.name + '/' + image.path + '.jpeg'
        # upload to dropbox
        r = client.put_file(path, f)
        pprint.pprint(r)
        
        # get some metadata
        m = client.media(r['path'])
        
        # update image in db
        image.url = m['url']
        image.path = r['path']
        image.save()

        # send email
        print 'webapp.views.upld_image - sending email using SendGrid'
        s = 'TakeNote(Beta) has uploaded your latest lecture notes to dropbox'
        b = 'Hello ' + request.user.first_name + ",\nTakeNote(Beta) has processed and uploaded the latest lecture notes to DropBox @ " + image.url + "\nHave Fun!"
        send_mail(s, b, 'raveen.b@gmail.com', [request.user.email], fail_silently=False)
        # email = SendGridEmailMessage(s, b, 'raveen.b@gmail.com', [request.user.email])
        # email.send()
        pprint.pprint(email)
    except Exception as e:
        print 'Exception: webapp.views.upld_image - ' + str(e)

# def has_new_files(request):
#     print 'webapp.views.has_new_files'
#     try:
#         client = request.session['dropbox_client']
#         p = request.user.get_profile()
#         d = client.delta(p.cursor)
#         pprint.pprint(d)
#         p.cursor = d.cursor # there could be more delta's not checking for them here
#         p.save()
#         return d.entries
#     except Exception as e:
#         print 'Exception: webapp.views.has_new_files - ' + str(e)
#         return None

def find_lectures(request):
    print 'webapp.views.find_lectures'
    client = request.session['dropbox_client']
    lectures = list()
    try:
        metadata = client.metadata('/')    
        if metadata.get('contents') is None:
            print 'webapp.views.find_lectures - No Content'
            return None
        for f in metadata['contents']:
            if f['is_dir'] == True:
                if not Lecture.objects.filter(user = request.user, name = f['path']).exists():
                    l = Lecture(user = request.user, 
                                name = f['path'], 
                                date = dateparse.parse_datetime(f['modified']),
                                done = False)
                    l.save()
                    lectures.append(l)
                else:
                    print 'webapp.views.find_lectures - lecture already exists'
        pprint.pprint(lectures)
        return lectures
    except Exception as e:
        print 'Exception: webapp.views.find_lectures - ' + str(e)
        return None


def find_images(request, lecture):
    print 'webapp.views.find_images'
    client = request.session['dropbox_client']        
    try:
        metadata = client.metadata(lecture.name)    
        if metadata.get('contents') is None:
            print 'webapp.views.find_images - No Content'
            return None
        for f in metadata['contents']:
            if 'image' in f['mime_type']:
                if not InputImage.objects.filter(user = request.user, path = f['path']).exists():
                    m = client.media(f['path'])
                    i = InputImage( user = request.user, 
                                    path = f['path'], 
                                    lecture = lecture, 
                                    date = dateparse.parse_datetime(f['modified']),
                                    url = m['url'])
                    i.save()
                    translate(i)
                else:
                    print 'webapp.views.find_images - image already exists'
    except Exception as e:
        print 'Exception: webapp.views.find_images - ' + str(e)
        return None

def translate(image):
    print 'webapp.views.translate - ' + str(image)
    # read from dropbox
    # do the translation
    # upload the translation to dropbox
    # update links in database
    # mark lecture as done
    # delete originals if needed
    l = image.lecture
    l.done = True
    l.save()

