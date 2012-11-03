Talks.Tokyo
===========

This projects is aimed at developing a system that makes organizing, managing, and sharing seminars (talks) easy.

This project is based on [Talks.Cam](http://www.talks.cam.ac.uk/). The source code was kindly provided by Center for Applied Research in Education Technologies (CARET), University of Cambridge through the svn [repository](http://source.caret.cam.ac.uk/svn/projects/talks.cam/).

Current status
--------------
Now it runs on the latest versions of rails 3.2.8 and ruby 1.9.3. However there are still many parts that depend on legacy codes. A new feature that enables adding a talk by just copy & paste is implemented (yippee!).

TODOs
-----
* Fix mailer.rb
* Fix A-Z index for Japanese.
* Support for non-latin characters in Ajax search.
* Write tests.
* Better, more coherent and intuitive URIs. Use resourceful routing.
* Better layout (for example, use drop down menus to group actions).
* Get rid of the warnings about Rails 2.3-style plugins in vendor/plugins.
* Replace error_messages_for (dynamic_form) with something more modern.
* Eliminate prototype.js dependency (and prototype_legacy_helper).
* Figure out which body_class helper function is called from which view.