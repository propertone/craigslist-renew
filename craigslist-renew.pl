#!/usr/bin/env perl
# This script logs in to your craigslist account and renews all posts that can be renewed
# The script should be invoked with a config file in yaml format containing the following info:
# ---
# email: <craigslist login>
# password: <craigslist password>
# notify: <comma separated list of emails>

use strict;
use warnings;
use WWW::Mechanize;
use Data::Dumper;
use MIME::Lite;
use HTML::TreeBuilder;
use HTML::TableExtract;
use Getopt::Long;
use YAML qw( LoadFile );
use List::MoreUtils qw( zip );
use File::Slurp qw( append_file );

my $mech = WWW::Mechanize->new();
my $renewed = 0;
my $check_expired;
GetOptions('expired' => \$check_expired);

defined($ARGV[0]) || die("Usage: $0 [--expired] <config.yml>\n");

my $config = LoadFile($ARGV[0]);
my $NOTIFY = $config->{notify};
my $SUBJECT = "Craigslist Automatic Renewal";
my $url = "https://accounts.craigslist.org/login";

$mech->get($url);

# log in with username and password
$mech->submit_form(
        fields      => {
            inputEmailHandle    => $config->{email},
            inputPassword       => $config->{password},
        }
    );

# once in a while, Craigslist verifies the login via Captcha, but this code is broken and fires everytime. -calexil

#$mech->quiet(1);
#if ($mech->form_with_fields('inputEmailHandle', 'inputPassword')) {
#    notify("Login failed - requires captcha");
#    exit(1);
#}
# $mech->quiet(0);

# filter active posts only, this code is also broken as the link 'active' is not found on the page -calexil
# $mech->follow_link(text=>"active");

# if --expired flag was specified, check for expired posts
if ($check_expired) {
    $SUBJECT = "Craigslist post expired";
    check_expired($mech->content);
    exit(0);
}

my $page = 1;
# loop thru all pages
while (1) {
    # look for all listings with a renew button
    my $n=1;
    my @forms;
    foreach my $form ($mech->forms) {
        if ($form->method() eq "POST") {
            my $input = $form->find_input('go');
            if ($input && $input->value() eq "renew") {
                push @forms, $n;
            }
        }
        $n++;
    }

    foreach my $form_id (@forms) {
        # click the renew button
        my $form = $mech->form_number($form_id);
        $mech->submit_form();
        if ($mech->content() =~  /Your posting can be seen at/) {
            # fetch the title and link of the confirmation page
            my $title=""; my $link="";
            my $root = HTML::TreeBuilder->new_from_content($mech->content());
            my @t = $root->look_down('_tag' => 'span', 'class' => 'postingtitletext');
            my @l = $root->look_down('_tag' => 'div', 'class' => 'managestatus')->look_down('_tag' => 'a', 'target' => '_blank');
            if (@t) {
                $title = $t[0]->as_trimmed_text();
            }
            if (@l) {
                $link = $l[0]->attr('href');
            }

            notify("Renewed \"$title\" (" . $link . ")");
            $renewed++;
        }
        else {
            notify("Could not renew post - " . $form->action );
        }
        $mech->back();

        # only renew the first posting unless renew_all is specified
        last unless $config->{renew_all};
    }

    $page = $page + 1;
    # if there is another page, go there
    if ($page > 5) {
        # don't go past 5 pages (maybe add config option for this later)
        last;
    }
    elsif ($mech->find_link(text=>$page)) {
        $mech->follow_link(text=>$page);
    }
    else {
        last;
    }

} # end while

# print message in interactive mode or send email when run from cron
sub notify {
    my $message = shift @_;

    # append to log, if specified
    if ($config->{logfile}) {
        my $ts = scalar localtime;
        my $email = $config->{email};
        my $line = "[$ts] $email: $message\n";
        append_file($config->{logfile}, {binmode => ':utf8' }, $line);
    }

    if (-t STDIN) {
        print "$message\n";
    }
    elsif (!$config->{'no_success_mail'} || $check_expired) {
        my $msg = MIME::Lite->new(
                    To      => $NOTIFY,
                    Subject => $SUBJECT,
                    Data    => $message,
                    );
        $msg->send;
    }
}

# the config file can list postings that should currently be active. This is specified in the config as:
# required:
#   - title: My Posting
#     area: nyc
#   - title: Another posting
#     area: nyc
sub check_expired {
    my ($content) = @_;
    my @columns = qw( status manage title area date id );
    my $te = HTML::TableExtract->new(headers=>\@columns);
    $te->parse($content);
    my @tables = $te->tables;
    my $ts = $tables[0];

    my $required = $config->{'postings'};
    foreach my $row ($ts->rows) {
        map {s/^\s*//gm;s/\s*$//gm;s/\n//g;} @$row;
        my %info = zip @columns, @$row;
        if ($info{'status'} =~ /active/i) {
            # check if this posting matches one of the required postings
            # if so, mark it as active in the required hash
            foreach my $posting (@$required) {
                my $title = $posting->{'title'};
                my $area = $posting->{'area'} // "";
                if ($info{'title'} =~ /$title/i and $info{'area'} =~ /$area/i) {
                    $posting->{'active'} = 1;
                }
            }
        }
    }
    my @expired = ();
    foreach my $posting (@$required) {
        if (!defined($posting->{'active'})) {
            push @expired, $posting->{'title'} . ' (' . $posting->{'area'} . ')';
        }
    }
    if (@expired) {
        my $msg = "The following posts have expired:\n\n" . join("\n", @expired);
        notify($msg);
    }
}
