FROM debian

WORKDIR /usr/src

RUN apt-get update \
    && apt-get install -y \
        perl \
        libwww-mechanize-perl \
        libhtml-tableextract-perl \
        libyaml-perl \
        liblist-moreutils-perl \
        libfile-slurp-perl \
        libmime-lite-perl \
    && rm -rf /var/lib/apt/lists

COPY craigslist-renew.pl /usr/src

ENTRYPOINT [ "/usr/bin/perl", "./craigslist-renew.pl", "/tmp/craigslist-renew.yml"]
