#!/usr/local/bin/perl

use strict;
use warnings;

use lib '/home/agentz/perllib';
#use Smart::Comments;
use DBI;
use utf8;
use Encode::Guess;
use Encode;

local $| = 1;

@ARGV or die "Usage: $0 <machine> <files...>\n<command> could be 'init' or 'import'\n";
my $machine;
my $sth;

my $dbh = DBI->connect(
    "dbi:Pg:dbname=test;host=localhost",
    'agentzh', 'agentzh',
    {AutoCommit => 1, RaiseError => 1, pg_enable_utf8 => 1, PrintError => 0, PrintWarn => 0}
);

    print "Creating schema restylog...\n";
    eval { $dbh->do('create schema restylog;'); };

sub create_table {
    my $ymd = shift;
    print "Creating schema restylog...\n";
    eval { $dbh->do('create schema restylog;'); };
    print "Setting search path to schema restylog...\n";
    $dbh->do('set search_path to restylog;');
    print "Creating the access table...\n";
    eval {
    $dbh->do(<<"_EOC_");

create table access_$ymd (
    id serial primary key,
    client_addr cidr,
    hostname varchar (127),
    requested timestamp (0) with time zone,
    method varchar(10),
    url varchar(2048),
    status integer,
    user_agent varchar (1024),
    response_size int,
    referrer varchar (1024),
    log_lineno integer,
    machine varchar (127),
    request_size integer,
    account varchar (256),
    -- latency integer,
    unique(client_addr, requested, log_lineno, machine)
);

_EOC_
    };
    if ($@) {
        warn $@;
    }
}

{
    $machine = shift @ARGV;
    if ($machine =~ /\.(?:log|txt)$/) {
        die "$machine does not look like a machine name to me.\n";
    }
    my @files = @ARGV;
    if (!@files) { die "No log file specified.\n"; }

    $dbh->do('set search_path to restylog;');
    print "Creating the access table...\n";


    #$sth = $dbh->prepare('
    #insert into access (
        #client_addr, hostname, requested, method, url, status, user_agent,
        #response_size, referrer, log_lineno, machine
        #) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        #');
    for my $file (@files) {
        print "\nProcessing log file $file...\n";
        import_file($file, 500);
    }
}

sub import_file {
    my ($file, $step) = @_;
    my $ymd;
    if ($file =~ m{\b(\d{4})/(\d{2})/(\d{2})\b}) {
        $ymd = $1.$2.$3;
        warn "YMD: $ymd\n";
    } else {
        die "Can't not get year/month/day from the input files' paths\n";
    }
    open my $in, $file or
        die "Can't open $file for reading: $!\n";
    create_table($ymd);
    my $prev = 'insert';
    my $buf;
    while (<$in>) {
        # 24.220.204.6 - - [02/Jul/2008:07:55:59 +0800] "Accept-Language: en" 400 349 "-" "-" - 0
        if (m{^(\S+) (\S+) \S+ \[([^]]+)\] "([^"]*)" (\d+) (\d+|-) "([^"]*)" "([^"]*)"(?: (\d+) (\d+))?}) {
            my ($ip, $host, $requested, $url, $status, $size, $referrer, $agent, $req_size, $time) = ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10);
            #warn "URL!!!! $url\n";
            my $meth;
            if ($url =~ m{^(\w+) ([^"]+) HTTP/\d+\.\d+$}) {
                ($meth, $url) = ($1, $2);
            } else {
                warn "!!!$url!!!";
                next;
            }
            ### $req_size
            ### $time
            $url =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
            my $enc = guess_enc($url);
            $url = decode($enc, $url);
            $referrer =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
            $enc = guess_enc($referrer);
            $referrer = decode($enc, $referrer);
            my $account;
            if ($url =~ m{/=/.*?\?.*?\buser=(\w+)}) {
                $account = $1;
                $account = $dbh->quote($account);
            } else {
                $account = 'null';
            }

            $url = $dbh->quote($url);
            $referrer = $dbh->quote($referrer);
            if ($size !~ /^\d+$/) { $size = 0 }
            $buf .= "insert into access_$ymd (
    client_addr, hostname, requested, method, url, status, user_agent,
    response_size, referrer, log_lineno, machine, request_size, account
    ) values ('$ip', '$host', '$requested', '$meth', $url, '$status', '$agent', $size, $referrer, $., '$machine', $req_size, $account);\n";
            if ($. % $step == 0) {
                insert_to_db(\$buf, \$prev);
            }
        } else {
            warn "\nSyntax error: line $.: $_";
        }
    }
    if ($buf) {
        insert_to_db(\$buf, \$prev);
    }
    close $in;
}

sub insert_to_db {
    my ($rbuf, $rprev) = @_;
    eval {
        $dbh->do($$rbuf);
    };
    undef $$rbuf;
    if ($@ && $@ =~ /duplicate key .*?violates unique constraint/) {
        if ($$rprev eq 'insert') { print "\n"; $$rprev = 'ignored' }
        print "\rignored $.";

    } else {
        if ($@) { warn "\n$@" }
        if ($$rprev eq 'ignored') { print "\n"; $$rprev = 'insert' }
        print "\rinserted $.";
    }
}

sub guess_enc {
    my $data = shift;
    my @enc = qw( utf-8 GB2312 Big5 GBK Latin1 );
    for my $enc (@enc) {
        my $decoder = guess_encoding($data, $enc);
        if (ref $decoder) {
#            if ($enc ne 'ascii') {
#                print "line $.: $enc message found: ", $decoder->decode($s), "\n";
#            }

            return $decoder->name;
        }
    }
    #warn "Can't determine the charset of the input.\n";
    #warn $data;
    return 'utf8';
}
__END__

accesslog module
accesslog.filename         = "|/home/es/sbin/cronolog /home/es/lighttpd14/log/light/%Y/%m/%d/access-%H.log"
accesslog.format = "%h %V %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %T"

