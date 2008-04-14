#!/usr/bin/perl -w

use strict;

use Test::Harness;

use lib "./lib";

runtests glob("./t/*.t");
