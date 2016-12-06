# craigslist-renew

This is a simple perl script that will auto-renew all your inactive Craigslist posts.

Requirements
------------
Only perl is necessary plus the following non-default modules, which you can download from CPAN:

* `WWW::Mechanize`
* `MIME::Lite`
* `HTML::TreeBuilder`
* `HTML::TableExtract`
* `YAML`
* `List::MoreUtils`
* `File::Slurp`
* `Mozilla::CA`

Installing Dependencies
-----
To install dependencies on debian-based distros, copy/paste the following in terminal:

* `sudo apt install libhttp-server-simple-perl libwww-mechanize-perl libxml-treebuilder-perl libxml-catalog-perl libmime-lite-perl libhtml-tableextract-perl libfile-slurp-perl libemail-date-format-perl libyaml-perl`

Usage
-----

Fill out the "config.yml" file with your craigslist credentials, and select the options you wish to use:

Then run the script from within the cloned directory with :

* `perl craigslist-renew.pl  config.yml`

Scheduling
-----

Then just schedule the script in cron to run at the schedule you want. Depending on the category and location, craigslist posts can be renewed about once every few days, so running the script every few hours should be more than sufficient:
```
0 */2 * * * /path/to/craigslist-renew.pl /path/to/config.yml
```
License
-------
M.I.T. Copyright (c) 2014 Vitaly Shupak <vitaly.shupak@gmail.com>  
CCA-4.0 2017 https://github.com/calexil
