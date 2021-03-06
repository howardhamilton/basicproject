import os
import sys

# Redirect sys.stdout to sys.stderr for bad libraries that use print
# statements for optional import exceptions.
sys.stdout = sys.stderr

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "settings")

from django.core.handlers.wsgi import WSGIHandler
application = WSGIHandler()
