"""
Django settings for DLVPEF project.

Generated by 'django-admin startproject' using Django 1.8.7.

For more information on this file, see
https://docs.djangoproject.com/en/1.8/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/1.8/ref/settings/

"""
import os
import sys

from django.utils.translation import ugettext_lazy as _
from django_jinja.builtins import DEFAULT_EXTENSIONS as \
    JINJA2_DEFAULT_EXTENSIONS


# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
# The root directory of the Django project.
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# The root directory of the project (the lowest level).
BASE_DIR_UP = os.path.dirname(BASE_DIR)

# Path to the custom Django applications.
sys.path.insert(1, os.path.join(BASE_DIR, 'apps'))

# The path to the server configuration - use `project_settings.py` file where
# you can override the `settings.py` parameters.
sys.path.insert(1, os.path.join(BASE_DIR_UP, 'world', 'etc'))

# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/1.8/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = '*b&^27kgh15^@2jw-e9ds5uvvf!6+9elpvb3)rpl^&5y*s-ht-'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True
ALLOWED_HOSTS = []

# Application definition
INSTALLED_APPS = (
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    'jinja2extensions',

    'audience',
)

MIDDLEWARE_CLASSES = (
    'django.contrib.sessions.middleware.SessionMiddleware',

    'solid_i18n.middleware.SolidLocaleMiddleware',

    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.auth.middleware.SessionAuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'django.middleware.security.SecurityMiddleware',
)

ROOT_URLCONF = 'basic.urls'

# TEMPLATES
# The templates are found in custom applications too.
_template_dirs = [os.path.join(BASE_DIR, 'website/templates'), ]
for root, dirs, files in os.walk(os.path.join(BASE_DIR, 'apps')):
    if 'templates' in dirs:
        _template_dirs.append(os.path.join(root, 'templates'))

TEMPLATES = [
    {
        'BACKEND': 'django_jinja.backend.Jinja2',
        'APP_DIRS': True,
        'DIRS': _template_dirs,
        'OPTIONS': {
            # Match the template names ending in .html but not the ones in the
            # admin folder.
            'match_extension': '.jinja',
            'match_regex': r'^(?!admin/).*',
            'app_dirname': 'templates',

            # Can be set to "jinja2.Undefined" or any other subclass.
            'undefined': None,
            'newstyle_gettext': True,
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
            'extensions': JINJA2_DEFAULT_EXTENSIONS + \
                ['{}.{}'.format('jinja2extensions.extensions', i) for i in [
                    'builtinfunctions.BuiltInFunctionsExtension',
                    'localizations.LocalizationsExtension',
                    'customvariables.CustomVariables',
                    'djangocompatibility.CsrfExtension',
                    'djangocompatibility.DatetimeExtension',
                    'sorlthumbnail.SorlThumbnailExtension',
                ]],
            'filters': {
                'defaults': 'jinja2extensions.filters.classic.defaults',
            },
            'autoescape': True,
            'auto_reload': DEBUG,
            'translation_engine': 'django.utils.translation',
        }
    },

    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'basic.wsgi.application'

# Database
# https://docs.djangoproject.com/en/1.8/ref/settings/#databases
DATABASES = {
    'default': {
        'ENGINE': 'mysql.connector.postgresql_psycopg2 ',
        'NAME': '<DATABASE>',
        'USER': '<USER>',
        'PASSWORD': '<PASSWORD>',
    }
}

# INTERNATIONALIZATION
# https://docs.djangoproject.com/en/1.8/topics/i18n/
# http://www.i18nguy.com/unicode/language-identifiers.html
LANGUAGE_CODE = 'en'
LANGUAGES = (
    ('en', _('English')),
    ('fr', _('France')),
)

# Other
TIME_ZONE = 'UTC'
USE_I18N = True
USE_L10N = True
USE_TZ = True

# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/1.8/howto/static-files/
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR_UP, 'world/var/www/static')
STATICFILES_DIRS = (
    os.path.join(BASE_DIR, 'website/static'),
)

# Media files.
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR_UP, 'world/var/www/media')

# Solid i18n.
SOLID_I18N_USE_REDIRECTS = True
SOLID_I18N_HANDLE_DEFAULT_PREFIX = False
SOLID_I18N_DEFAULT_PREFIX_REDIRECT = False
# JINJA2DJANGO_TRANSLATED_URL_HEAD_PREFIX = False

# Loading extension parameters of standard configurations.
# Used to load various options on the server and on your local computer.
# ** If options are not loaded this point is ignored.
try:
    from local_settings import *
except ImportError:
    pass

