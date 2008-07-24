#!/bin/sh

egrep '^type=PgFarm' etc/site_openresty.conf && echo "PgFarm is used. Aborted." && exit
echo "removing accounts..."
bin/openresty deluser agentzh
bin/openresty deluser tester2
bin/openresty deluser tester
bin/openresty deluser _global
echo "creating new accounts..."
(echo password ; echo password) | bin/openresty adduser tester
(echo password2 ; echo password2) | bin/openresty adduser tester2
(echo password ; echo password) | bin/openresty adduser agentzh

