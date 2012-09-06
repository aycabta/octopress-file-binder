File Binder for Octopress
=========================

Description:
------------
Attach some images or other files to the entry.

Usege:
------

If you wrote a entry in "source/_posts/YYYY-DD-MM-title-of-a-entiry.markdown",
you can attach the files that are given the name of
"source/_posts/YYYY-DD-MM-title-of-a-entiry_filename-of-image.png" for example.
The attached files puts out into the same directory of the entry by the name of "filename-of-image.png",
in this case it is "public/blog/YYYY/DD/MM/title-of-a-entry/filename-of-image.png".
You can refer the files from the entry by img or others tags.

Replace "./" that is head of src in a img tag with config['url'] + "/blog/YYYY/DD/MM/title-of-a-entry/".
config['url'] is written in _config.yml with "url: ".
So src is published absolute path without problems
if you write {% img ./filename-of-image.png %}.

Support customized permalink in _config.yml that is different from "/blog/:year/:month/:day/:title/".

License:
--------
Distributed under the [MIT License][MIT].

[MIT]: http://www.opensource.org/licenses/mit-license.php

