Talks.Tokyo
===========

This projects is aimed at developing a system that makes organizing, managing, and sharing seminars (talks) easy.

This project is based on [Talks.Cam](http://www.talks.cam.ac.uk/). The source code was kindly provided by Center for Applied Research in Education Technologies (CARET), University of Cambridge through the svn [repository](http://source.caret.cam.ac.uk/svn/projects/talks.cam/).

Current status
--------------
Now it runs on the latest versions of rails 3.2.8 and ruby 1.9.3. However there are still many parts that depend on legacy codes. A new feature that enables adding a talk by just copy & paste is implemented (yippee!).

TODOs
-----
* <del>Fix the positions of helps for edit.</del>
* Remove mentions to talks.cam.
* Internationalization (including date format, support for venue names in multiple languages, and the whole site).
* <del>Short and long date formats (in Japanese and English).</del>
* <del>Fix SmartForm so that it scrolls down. Also check that it looks ok with different browsers.</del>
* Add "bio" field in SmartForm.
* <del>Fix mailer.rb. Email reminder.</del> (almost)
* <del>"Review" function that allows non-organizers to add talks and request the organizers to approve them.</del>
* Count down days.
* Fix A-Z index for Japanese.
* <del>Support for non-latin characters in Ajax search.</del>
* Write tests.
* Better, more coherent and intuitive URIs. Use resourceful routing.
* Better layout (for example, use drop down menus to group actions).
* Get rid of the warnings about Rails 2.3-style plugins in vendor/plugins.
* Replace error_messages_for (dynamic_form) with something more modern.
* <del>Eliminate prototype.js dependency (and prototype_legacy_helper).</del>
* Figure out which body_class helper function is called from which view.
