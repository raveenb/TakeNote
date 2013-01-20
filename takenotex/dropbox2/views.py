from django.http import HttpResponseRedirect
from django.conf import settings
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.models import User
from django.contrib.auth.decorators import login_required
from django.views.decorators.csrf import csrf_exempt
from django.http import urlencode

from dropbox import client, rest, session
from models import UserProfile
import pprint

# /login
def oauth_login(request):
    print 'dropbox.views.oauth_login'
    # Step 0. Get the current hostname and port for the callback
    if request.META['SERVER_PORT'] == 443:
        current_server = "https://" + request.META['HTTP_HOST']
    else:
        current_server = "http://" + request.META['HTTP_HOST']
    oauth_callback = current_server + "/login/authenticated"

    # Step 1. Get a request token from Provider.
    sess = session.DropboxSession(settings.DROPBOX_KEY, settings.DROPBOX_SECRET, settings.DROPBOX_ACCESS)
    request_token = sess.obtain_request_token()
    url = sess.build_authorize_url(request_token)

    # Step 2. Store the request token in a session for later use.
    request.session['dropbox_request_token'] = request_token
    request.session['dropbox_session'] = sess

    # Step 3. Redirect the user to the authentication URL.
    param = urlencode({'oauth_callback': oauth_callback})
    url = url + '&' + param
    print url
    return HttpResponseRedirect(url)

# /logout (requires login)
@login_required
def oauth_logout(request):
    # Log a user out using Django's logout function and redirect them
    # back to the homepage.
    print 'dropbox.views.oauth_logout'
    logout(request)
    return HttpResponseRedirect('/')

#/login/authenticated/
def oauth_authenticated(request):
    print 'dropbox.views.oauth_authenticated'
    # Step 1. Use the request token in the session to build a new client.
    # Step 2. Request the authorized access token from Provider.
    sess = request.session['dropbox_session']
    access_token = sess.obtain_access_token(request.session['dropbox_request_token'])
    print access_token
    pprint.pprint(access_token)
    print "Access Token:"
    print "    - oauth_token        = %s" % access_token.key
    print "    - oauth_token_secret = %s" % access_token.secret
    print
    dropbox_client = client.DropboxClient(sess)
    profile = dropbox_client.account_info()
    print profile

    try:
        user = User.objects.get(username = profile['uid'])
    except User.DoesNotExist:
        print 'Info: dropbox.views.oauth_authenticated - User DoesNotExist, creating one'
        user = User.objects.create_user(profile['uid'], profile['email'], 'password') # this is dangerous
        user.first_name = profile['display_name']
        user.last_name = ""
        user.save()
        # Save our permanent token and secret for later.
        print 'dropbox.views.authenticate - creating user profile'
        userprofile = UserProfile()
        userprofile.user = user
        userprofile.oauth_token = access_token.key
        userprofile.oauth_secret = access_token.secret
        userprofile.access_token = access_token
        userprofile.save()

    # Authenticate the user and log them in using Django's pre-built
    # functions for these things.
    user = authenticate(username = profile['uid'], password = 'password')
    if user is not None:
        login(request, user)
        print 'dropbox.views.authenticate - user logged in'
        request.session['dropbox_client'] = dropbox_client  
    else:
        print 'Error: dropbox.views.oauth_authenticate - user not authenticated'
    return HttpResponseRedirect(settings.LOGIN_REDIRECT_URL)

