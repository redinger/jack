jack
    by Rick Olson
    http://rubyforge.org/projects/activereload

== DESCRIPTION:
  
FIX (describe your package)

== FEATURES/PROBLEMS:
  
* FIX (list of features or problems)

== SYNOPSIS:

  FIX (code sample of usage)

== REQUIREMENTS:

* Rake
* open4
* ffmpeg (optional)
* TMail gem (optional)
* aws-s3 gem (optional)
* appcast gem (optional)
* lockfile gem (optional)

You can freeze the optional gems like so:

  $ mkdir -p vendor/tmail
  $ svn export http://tmail.rubyforge.org/svn/trunk/lib vendor/tmail/lib

  $ mkdir -p vendor/aws-s3
  $ svn export http://amazon.rubyforge.org/svn/s3/trunk/lib vendor/aws-s3/lib

	$ mkdir -p vendor/appcast
	$ svn export http://ar-code.svn.engineyard.com/appcast/trunk/lib vendor/appcast/lib

== INSTALL:

* gem install jack

== LICENSE:

(The MIT License)

Copyright (c) 2007 Rick Olson

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
