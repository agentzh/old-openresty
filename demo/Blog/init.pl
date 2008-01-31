#!/usr/bin/env perl

use strict;
use warnings;

use YAML::Syck 'Dump';
use lib '/home/agentz/hack/openapi/trunk/lib';
use WWW::OpenAPI::Simple;

my $openapi = WWW::OpenAPI::Simple->new( { server => 'http://localhost' } );
$openapi->login('agentzh', 4423037);
$openapi->delete("/=/model");

$openapi->post({
    description => "Blog post",
    columns => [
        { name => 'title', label => 'Post title' },
        { name => 'content', label => 'Post content' },
        { name => 'author', label => 'Post author' },
        { name => 'created', default => ['now()'], type => 'timestamp(0) with time zone', label => 'Post creation time' },
    ],
}, '/=/model/Post');

$openapi->post({
    description => "Blog comment",
    columns => [
        { name => 'sender', label => 'Comment sender' },
        { name => 'email', label => 'Sender email address' },
        { name => 'body', label => 'Comment body' },
        { name => 'created', default => ['now()'], type => 'timestamp(0) with time zone', label => 'Comment creation time' },

    ],
}, '/=/model/Comment');

print Dump($openapi->get('/=/model')), "\n";
#print Dump($openapi->get('/=/model/Post')), "\n";
#print Dump($openapi->get('/=/model/Comment')), "\n";

