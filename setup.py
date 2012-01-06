from distutils.core import setup
from distutils.extension import Extension

SPEEX = Extension("speex", 
                  ["speex.c"],
                  libraries = ["speex"])

ext_modules = [SPEEX]
                      
setup(
  name = 'Speex',
  description = 'Speex Python interface',
  author = 'Jeremy Slater',
  author_email = 'jasl8r@alum.wpi.edu',
  ext_modules = ext_modules
)

