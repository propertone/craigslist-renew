# craigslist-renew

This is a simple perl script that will auto-renew all your inactive Craigslist posts. It can also notify you when a post expires.

Requirements
------------
Only perl is necessary plus the following non-default modules, which you can download from CPAN:

* `WWW::Mechanize`
* `MIME::Lite`
* `HTML::TableExtract`
* `YAML`
* `List::MoreUtils`
* `File::Slurp`
* `Mozilla::CA`
* `LWP::Protocol::https`


Usage
-----

Create a yaml config file with the following content:
```
---
#
# Required parameters
#
email: <craigslist login>
password: <craigslist password>
notify: <comma separated list of emails>
#
# Optional parameters
#
# specify sender email address
from: <sender email address>
# set to 1 to suppress notification emails on renewal
no_success_mail: <1|0>
# set to 1 to renew all posts available for renewal
# By default, only the first expired post gets renewed on each run
renew_all: <1|0>
# specify path for logging actions taken
logfile: <path-to-logfile>
# specify the list of your current postings for expiration notifications
postings:
  - title: My post
    area: nyc
  - title: Another post
    area: nyc
```

Then just schedule the script in cron to run at the schedule you want. Depending on the category and location, craigslist posts can be renewed about once every few days, so running the script every few hours should be more than sufficient:
```
0 */2 * * * /path/to/craigslist-renew.pl /path/to/config.yml
```

You can only renew a post so many times before it expires, so to get notified about expired posts, make sure you have configured the `postings` parameter in your configuration and add the following (daily) cronjob:
```
0 21 * * * /path/to/craigslist-renew.pl --expired /path/to/config.yml
```

Docker usage
------------
To avoid installing a perl environment with all its dependencies you can run this script in a Docker container.

WARNING: email notifications are not tested with this Docker container.

### Pre-requirements:
To have it working you need to map two files into the container:

- `/tmp/craigslist-renew.yml` config file (required)
- `/tmp/craigslist-renew.log` log file (optional)

### Running it:
```
# Build container
make docker-build
# Alternatively
docker build -t craigslist-renew .

# Execute craigslist-renew.pl without --expired flag (default)
#     The logfile mapping is optional can can be left alone
docker run \
    --rm -it \
    -v "/path/to/craigslist-renew.yml:/tmp/craigslist-renew.yml:ro" \
    -v "/path/to/logfile.log:/tmp/craigslist-renew.log" \
    craigslist-renew

# Execute craigslist-renew.pl with the --expired flag
#     The logfile mapping is optional can can be left alone
docker run \
    --rm -it \
    -v "/path/to/craigslist-renew.yml:/tmp/craigslist-renew.yml:ro" \
    -v "/path/to/logfile.log:/tmp/craigslist-renew.log" \
    --entrypoint /usr/bin/perl \
    craigslist-renew \
        ./craigslist-renew.pl --expired /tmp/craigslist-renew.yml
```


License
-------
The MIT License (MIT)

Copyright (c) 2014 Vitaly Shupak <vitaly.shupak@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
