Talks.Tokyo
===========

This projects is aimed at developing a system that makes organizing, managing, and sharing seminars (talks) easy.

This project is based on [Talks.Cam](http://www.talks.cam.ac.uk/). The source code was kindly provided by Center for Applied Research in Education Technologies (CARET), University of Cambridge through the svn [repository](http://source.caret.cam.ac.uk/svn/projects/talks.cam/).

Current status
--------------
Now it runs on the latest versions of rails 3.2.8 and ruby 1.9.3. However there are still many parts that depend on legacy codes. A new feature that enables adding a talk by just copy & paste is implemented. A more modern design with dropdown menus and calendar based on jQuery and Twitter Bootstrap.

TODOs
-----
* Should be able to remove talks and lists from a list.
* Personal list must be private.
* Invite functionality
* <del>Fix response when trying to remove a talk from its series.</del>
* <del>apple-touch-icon.png</del>
* <del>use _url instead of _path in show (for embedding)</del>
* <del>CSS for printing</del>
* <del>Fix include/talk url in tickes.</del>
* <del>Add email type in create user view.</del>
* <del>Do not show canceled talks in users' profile page.</del>
* <del>Replace map with jQuery.each to support IE8.</del>
* <del>Keep nav bar at the top.</del>
* <del>Special message.</del>
* Remove behavior.js dependency.
* Buttons to show/hide talks in home view.
* <del>Fix CSS for the embedded view.</del>
* <del>Reorganize list view (icons, further details, custom views, etc)</del>
* <del>Show lists that a talk belongs to in home. Different colors for lists.</del>
* Show recently viewed talks.
* <del>Fix the positions of helps for edit.</del>
* <del>Remove mentions to talks.cam.</del>
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
