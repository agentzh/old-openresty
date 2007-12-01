#!/usr/bin/env perl
# OpenAPI implementation

use strict;
use warnings;
#use subs 'warn';

#$SIG{__WARN__} = sub { print @_; };
#$SIG{__DIE__} = sub { print @_;  };

use FindBin;
use lib "$FindBin::Bin";
use OpenAPI;
use URI;
#use Web::Scraper;
use CGI::Fast qw(:standard);
use Data::Dumper;
#use XML::Simple qw(:strict);
use FindBin;
use DBI;
use Smart::Comments;
#use Perl6::Say;

$CGI::POST_MAX = 1024 * 1000;  # max 1000K posts
#$CGI::DISABLE_UPLOADS = 1;  # no uploads
my $LastError;

# XXX Excpetion not caputred...when database 'test' not created.
eval {
    OpenAPI->connect();
};
if ($@) {
    $LastError = $@;
}

my $ext = qr/\.(?:js|json|xml|yaml|yml)/;
my $COUNTER = 0;
while (my $query = new CGI::Fast) {
    my $url  = url(-absolute=>1);
    print header(-type => 'text/plain');
    #print "URL: $url\n";
    #print "page: ", url_param("page"), "\n";
    #warn "Hello!";
    #print "charset: ", url_param("charset"), "\n";
    if ($LastError) {
        print OpenAPI->emit_error($LastError), "\n";
        undef $LastError;
    }
    my $data;
    ### Content-type: content_type()
    my $user = 'test';
    eval {
        #OpenAPI->drop_user($user);
    };
    if ($@) { warn $@; }
    if (my $retval = OpenAPI->has_user($user)) {
        ### Found user: $user
    } else {
        ### Creating new user: $user
        OpenAPI->new_user($user);
    };
    eval {
        OpenAPI->do("SET search_path TO $user,public");
    };
    if ($@) { print OpenAPI->emit_error($@), "\n"; next; }
    $url =~ s/\%2A/*/g;
    my $method = $ENV{'REQUEST_METHOD'};
    if ($method eq 'GET') {
        ### GET method detected: $url
        if ($url =~ m{^/=/model($ext)?$}) {
            OpenAPI->set_formatter($1);
            ### Showing model list with ext: $ext
            my $models;
            eval {
                $models = OpenAPI->get_models;
            };
            if ($@) {
                print OpenAPI->emit_error($@);
                next;
            }
            $models ||= [];
            ### $models
            map { $_->{src} = "/=/model/$_->{name}" } @$models;
            print OpenAPI->emit_data($models), "\n";
        } elsif ($url =~ m{^/=/model/(\w+)($ext)?$}) {
            my ($model, $ext) = ($1, $2);
            OpenAPI->set_formatter($ext);
            ### Showing model $table with ext: $ext
            my $res;
            eval {
                $res = OpenAPI->get_model_cols($model);
            };
            if ($@) {
                print OpenAPI->emit_error($@), "\n";
                next;
            }
            ### $res
            print OpenAPI->emit_data($res), "\n";
        } elsif ($url =~ m{^/=/model/(\w+)/\*/\*($ext)?$}) {
            my ($model, $ext) = ($1, $2);
            OpenAPI->set_formatter($ext);
            ### Showing all the records: $url
            my $res;
            eval {
                $res = OpenAPI->select_all_records($model);
            };
            if ($@) {
                print OpenAPI->emit_error($@), "\n";
                next;
            }
            print OpenAPI->emit_data($res), "\n";
        } elsif ($url =~ m{^/=/model/(\w+)/(\w+)/\*($ext)?$}) {
            my ($model, $column, $ext) = ($1, $2, $3);
            OpenAPI->set_formatter($ext);
            ### Showing one field of all records:
            my $res;
            eval {
                $res = OpenAPI->select_records($model, $column);
            };
            if ($@) {
                print OpenAPI->emit_error($@), "\n";
                next;
            }
            ### $res
            print OpenAPI->emit_data($res), "\n";
        } elsif ($url =~ m{^/=/model/(\w+)/(\w+)/(.+?)($ext)?$}) {
            my ($model, $column, $value, $ext) = ($1, $2, $3, $4);
            OpenAPI->set_formatter($ext);
            #### Showing selected records: $url
            my $res;
            eval {
                $res = OpenAPI->select_records($model, $column, $value);
            };
            if ($@) {
                print OpenAPI->emit_error($@), "\n";
                next;
            }
            ### $res
            print OpenAPI->emit_data($res), "\n";
        }
    } elsif ($method eq 'DELETE') {
        ### DELETE method detected: $url
        if ($url =~ m{^/=/model($ext)?$}) {
            OpenAPI->set_formatter($1);
            ### Deleting all the models...
            my $res;
            eval {
                $res = OpenAPI->get_tables($user);
            };
            if ($@) { print OpenAPI->emit_error($@), "\n"; next; }
            if (!$res) {
                print OpenAPI->emit_success(), "\n";
                next;
            }; # no-op
            my @tables = map { @$_ } @$res;
            #$tables = $tables->[0];
            ### tables: @tables
            my $failed = 0;
            for my $table (@tables) {
                eval {
                    OpenAPI->drop_table($table);
                };
                if ($@) {
                    $failed = 1;
                    last;
                }
            }
            if ($failed) {
                print OpenAPI->emit_error($@), "\n";
                next;
            }
            print OpenAPI->emit_success(), "\n";
         } elsif ($url =~ m{^/=/model/(\w+)/(\w+)/(.+?)($ext)?$}) {
            my ($model, $column, $value, $ext) = ($1, $2, $3, $4);
            OpenAPI->set_formatter($ext);
            #### Showing selected records: $url
            my $res;
            eval {
                $res = OpenAPI->delete_records($model, $column, $value);
            };
            if ($@) {
                print OpenAPI->emit_error($@), "\n";
                next;
            }
            ### $res
            print OpenAPI->emit_data($res), "\n";
        } else {
            print OpenAPI->emit_error("Operation unsupported."), "\n";
        }
    } elsif ($method eq 'POST') {
        ### POST method detected: $url
        # XXX check for content-type...
        $data = param('POSTDATA');
        ### $data
        if (!defined $data) {
            print OpenAPI->emit_error("No POST content specified."), "\n";
            next;
        }
        $data = OpenAPI->parse_data($data);
        if ($url =~ m{^/=/model/(\w+)($ext)?$}) {
            my ($model, $ext) = ($1, $2);
            OpenAPI->set_formatter($ext);
            $data->{name} = $model;
            my $res;
            eval {
                $res = OpenAPI->new_model($data);
            };
            if ($@) {
                print OpenAPI->emit_error($@), "\n";
                next;
            }
            print OpenAPI->emit_data($res), "\n";
        } elsif ($url =~ m{^/=/model/(\w+)/\*/\*($ext)?$}) {
            my ($model, $ext) = ($1, $2);
            OpenAPI->set_formatter($ext);
            my $res;
            eval {
                $res = OpenAPI->insert_records($model, $data);
            };
            if ($@) {
                print OpenAPI->emit_error($@), "\n";
                next;
            }
            print OpenAPI->emit_data($res), "\n";
        }
        ### POST data: $data
    } elsif ($method eq 'PUT') {
        ### PUT method detected: $url
        $data = $query->param('PUTDATA');
        #print $data;
        #next;
        #warn Dumper($query);
        #warn $CGI::VERSION;
        ### $data
        #print $data;
        if (!$data) {
            print OpenAPI->emit_error("No PUT content specified."), "\n";
            next;
        }
        $data = OpenAPI->parse_data($data);
        if ($url =~ m{^/=/model/(\w+)/(\w+)/(.+?)($ext)?$}) {
            my ($model, $column, $value, $ext) = ($1, $2, $3, $4);
            OpenAPI->set_formatter($ext);
            #### Updating selected records: $url
            my $res;
            eval {
                $res = OpenAPI->update_records($model, $column, $value, $data);
            };
            if ($@) {
                print OpenAPI->emit_error($@), "\n";
                next;
            }
            ### $res
            print OpenAPI->emit_data($res), "\n";
        }
    }
    #print Dumper($query);
    #print Dumper(\%ENV);
}

