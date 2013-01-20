from django.conf.urls import patterns, include, url

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'takenotex.views.home', name='home'),
    # url(r'^takenotex/', include('takenotex.foo.urls')),

    # Uncomment the admin/doc line below to enable admin documentation:
    # url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    url(r'^admin/', include(admin.site.urls)),
    # (r'^accounts/login/$', 'django.contrib.auth.views.login'),
)

urlpatterns += patterns('webapp.views',
    url(r'^$', 'start'),
    url(r'^home/$', 'home'),
    url(r'^add_lecture/$', 'add_lecture'),
    url(r'^add_image/$', 'add_image'),
    # url(r'^add_story_to_position/(?P<id>\d+)/$', 'add_story_to_position'),
)

urlpatterns += patterns('dropbox2.views',
    url(r'^login/?$', 'oauth_login'),
    url(r'^logout/?$', 'oauth_logout'),
    url(r'^login/authenticated/?$', 'oauth_authenticated'),
)

