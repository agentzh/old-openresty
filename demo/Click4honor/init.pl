use strict;
use warnings;

use utf8;
use Getopt::Std;
use WWW::OpenResty::Simple;

my %opts;
getopts('u:s:p:h', \%opts);
if ($opts{h}) {
    die "Usage: $0 -u <user> -p <password> -s <openresty_server>\n";
}
my $user = $opts{u} or
    die "No OpenResty account name specified via option -u\n";
my $password = $opts{p} or
    die "No OpenResty account's Admin password specified via option -p\n";
my $server = $opts{s} || 'http://api.openresty.org';

my $resty = WWW::OpenResty::Simple->new( { server => $server } );
$resty->login($user, $password);
$resty->delete("/=/role/Public/~/~");
$resty->delete("/=/role");
$resty->delete("/=/view");
$resty->delete("/=/feed");

my $model = 'Honorlist';
if ($resty->has_model($model)) {
    print STDERR "Are you sure to remove the $model model first?";
    my $ans = <STDIN>;
    if ($ans =~ /^[Yy]/) {
        $resty->delete("/=/model/$model");
    } else {
        die "Model $model already exists.\n";
    }
}

$resty->post(
    "/=/model/$model",
    { description => 'Honor list',
      columns => [
        { name => 'w', label => 'Where you are fighting for' },
        { name => 'c', label => 'Click count', type => 'integer' }
      ]
    }
);

$resty->post(
    "/=/view/Honorlist",
    { definition => 'select * from Honorlist order by c desc limit $limit|500' }
);

$resty->post(
    "/=/role/Public/~/~",
    [
        { url => '/=/model/Honorlist/~/~' },
        { url => '/=/view/Honorlist/~/~' }
    ]
);

$resty->post(
    "/=/role/Poster",
    { description => 'My role requiring captchas',
      login => 'captcha' }
);

$resty->post(
    "/=/role/Poster/~/~",
    [
        { method => 'POST', url => '/=/model/Honorlist/~/~' },
        { method => 'PUT', url => '/=/model/Honorlist/~/~' }
    ]
);

