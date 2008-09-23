package SpringBot;

use strict;
use warnings;

use utf8;
#use Smart::Comments;

use base 'Bot::BasicBot';
use Encode::Guess;
use Encode qw(from_to encode decode);
use WWW::OpenResty::Simple;
use Params::Util qw(_ARRAY);
use Digest::MD5 qw(md5_hex);

use LWP::UserAgent;
my $ua = LWP::UserAgent->new;
$ua->timeout(2);
$ua->env_proxy;

$SIG{CHLD} = "IGNORE";

our @Brain = (
    [0 => qr{https?://[^\(\)（）？。]+} => \&process_url],
    [0 => qr{(?:哈你个头|ｆｕｃｋ|f\s*u\s*c\s*k|[^A-Za-z]TMD[^A-Za-z]|\bTMD\b|\bshit\b|\bf[us\*]ck(?:ing)?\b|\bdammit\b|\bdamn(?:\s+it)?\b|\bbastard\b|perl.*?邪教|\bMD\b)}i => \&punish_him],
    [1 => qr{^\s*baidu\s+}i => \&baidu_stuff],
    [0 => qr{^\s*emp(?:loyee)?\s+} => \&find_employee],
    [1 => qr{.} => \&reply_crap],
    [0 => qr{^\s*seen\s+([^?？]+)\s*[?？]?\s*$} => \&seen_person],
);

our %EncodingMap = (
    'cp936' => 'gbk',
    'utf8'  => 'utf8',
    'euc-cn' => 'gbk',
    'big5-eten' => 'big5',
);

our $Resty;

sub new {
    my $proto = shift;
    my %args = @_;
    my $account = delete $args{resty_account} or die "No account given";
    my $password = delete $args{resty_password} or die "No password given";

    $Resty = WWW::OpenResty::Simple->new(
        { server => 'api.openresty.org' }
    );
    $Resty->login($account, $password);
    my $self = $proto->SUPER::new(%args);
    $self->{_resty_account} = $account;
    $self->{_resty_password} = $password;
    ### $self
    $self;
}

sub resty_account {
    return $_[0]->{_resty_account};
}

sub resty_password {
    return $_[0]->{_resty_password};
}

sub channel {
    $_[0]->{bot_channel};
}

sub said {
    my ($self, $e) = @_;
    my $text = $e->{raw_body};
    my $sender = $e->{who};
    my $channel = $e->{channel};
    $self->{bot_channel} = $channel;
    #$self->{channel} = $channel;
    ### said: $e

    my $orig_text = $text;
    $orig_text =~ s/[ \n]+$//gs;
    #warn "public: $text";
    my $charset = $self->charset;
    ### charset: $charset
    my $say = sub {
        my $msg = shift;
        #from_to($msg, 'utf8', $charset);
        #use Encode qw(is_utf8 decode);
        #print $msg;
        #log_error($msg);
        #print "Hello............................\n";
        #print "howdy............................\n";
        eval {
            for my $line (split /\n+/, $msg) {
                next if $line =~ /^\s*$/;
                $self->say(
                    channel => $channel,
                    body => $line,
                );
                $self->log($channel, $self->nick, $line);
            }
        };
        if ($@) { $self->log_error($@); }
    };
    my $enc = guess_charset($text, $charset);
    log_error("msg in charset: $enc\n");
    log_error("Charset:  $charset\n");
    #from_to($text, $enc, 'utf8');
    #warn length($orig_text);
    #if (length($orig_text) > 4 and $enc ne 'ascii' and $enc ne $charset and $text !~ /^\[\w+\]: /) {
    #warn "Hit!\n";
    #$say->("[$enc]: $text\n");
    #}
    $self->process_msg($text, $say, $sender);
    $self->log($e->{channel}, $e->{who}, $e->{raw_body});
    return undef;
}

sub log_error {
    my $error = shift;
    #print $error;
    warn $error;
    open my $out, '>>springbot.error';
    if ($out) {
        print $out "Hello!!! >>>>>> log ", scalar(localtime), "\n";
        print $out $error, "\n";
        close $out;
    }
}

sub handler {
}

sub log {
    my ($self, $channel, $sender, $body, $type) = @_;
    $type ||= 'msg';
    return unless defined $channel and defined $sender and defined $body;
    my $s = "[log]: $channel: $sender: $body: $type\n";
    #print encode('utf8', $s);
    $self->forkit(
        channel => $channel,
        handler => 'handler',
        run => sub {
            use File::Slurp;
            #warn "HEY! I'm logging!\n";
            my $res;
            eval {
                $res = $Resty->post(
                    '/=/model/IrcLog/~/~',
                    { _user => $self->resty_account,
                      _password => md5_hex($self->resty_password) },
                    {
                        channel => $channel,
                        sender  => $sender,
                        content => $body,
                        type    => $type,

                    }
                );
            };
            if ($@) {
                log_error($@);
            } else {
                #use Data::Dumper;
                #log_error(Dumper($res));
            }
            ### Insert log message: $res
        }
    );
}

sub pick {
    my ($list) = @_;
    my $len = @$list;
    my $i = int rand ($len);
    warn $i;
    $list->[$i];
}

sub process_msg {
    my ($self, $orig_text, $say, $sender) = @_;
    ### $orig_text
    my $nick = $self->nick;
    for my $item (@Brain) {
        #### $item
        my $text = $orig_text;
        my ($explicit, $pattern, $handle) = @$item;
        my $is_explicit = ($text =~ s/^\s*\Q$nick\E\s*[:：]\s*//);
        ### $text
        ### $is_explicit
        if ($explicit) {
            next unless $is_explicit;
        }
        if ($text =~ m{$pattern}) {
            $handle->($self, $pattern, $text, $&, $say, $sender);
            last;
        }
    }
}

sub process_url {
    my ($self, $pattern, $text, $url, $say, $sender) = @_;
    my $charset = $self->charset;
    #$say->("Found URL: $match");
    if ($url =~ /\.(?:avi|iso|msi|tar|gz|bz2|rpm|deb|dll|so|exe|mp3|rm|rmvb|bak|txt|jpg|jpeg|png|xml|tiff|gif|mov|flw|swf|sql)\b/i) { return; }
    warn "Getting $url...\n";
    $ua->max_size( 1024 * 3 );
    $ua->timeout(3);
    my $res = $ua->get($url);
    if (!$res->is_success) {
        warn $res->status_line;
        return;
    }
    my $content = $res->content;
    if (defined $content) {
        if ($content =~ m{<title>(.*?)</title>}is) {
            my $title = $1;
            $title =~ s/\n+//gs;
            $title =~ s/\s+/ /g;
            my $enc = guess_charset($title, $charset);
            ### $title
            $title = decode($enc, $title);
            ### $enc
            $say->($title);
        }
    } else {
        warn "Failed to get $url.\n";
    }
}

sub baidu_stuff {
    my ($self, $pattern, $text, $cmd, $say, $sender) = @_;
    ### $pattern
    ### $text
    ### $cmd
    $text =~ s/$pattern//;
    #warn "CMD: $text";
    $text =~ s/\n+//sg;
    ### $text
    if ($text) {
        use LWP::Simple;
        $text = encode('gbk', $text);
        my $url = "http://www.baidu.com/s?wd=$text";
        ### $url
        my $content = get($url);
        if (!$content) {
            warn "Cannot open $url\n";
            return;
        }
        if ($content =~ m{<a [^>]*?href="([^"]+)" target="_blank"><font size="3">(.+?)</font></a>}i) {
            my ($url, $title) = ($1, $2);
            $title = html2text($title);
            my $msg = "$title ( $url )";
            $msg = decode('gbk', $msg);
            #print $say;
            $say->("$sender: $msg");
        }
    }

}

sub seen_person {
    my ($self, $pattern, $text, $matched, $say, $sender) = @_;
    my $channel = $self->channel;
    if ($text =~ m/$pattern/) {
        my $sender = $1;
        my $res;
        eval {
            $res = $Resty->get(
                '/=/view/LastSeen/~/~',
                { sender => $sender, _user => $self->resty_account, _password => $self->resty_password }
            );
        };
        if ($@) { $self->log_error($@); return }
        if (_ARRAY($res)) {
            my $row = $res->[0];
            use DateTime;
            use DateTime::Duration;
            use DateTime::Format::Pg;
            use DateTime::Format::Duration;
            my $sent_on = DateTime::Format::Pg->parse_timestamp_with_time_zone($row->{sent_on});
            my $now = DateTime->now;
            my $duration = $now - $sent_on;
            #my $duration = DateTime::Duration->new(
            #years => 3,
            #months => 2,
            #days => 15,
            #hours => 13,
            #    minutes => 35,
            #seconds => 55
            #);
            my @s;
            if (my $years = $duration->years) {
                push @s, "$years years";
            }
            if (my $months = $duration->months) {
                push @s, "$months months";
            }
            if (my $days = $duration->days) {
                push @s, "$days days";
            }
            if (my $hours = $duration->hours) {
                push @s, "$hours hours";
            }
            if (my $minutes = $duration->minutes) {
                push @s, "$minutes minutes";
            }
            if (my $seconds = $duration->seconds) {
                push @s, "$seconds seconds";
            }
            my $s = join(', ', @s);
            $s =~ s/.*,/$& and /;
            my $content = $row->{content};
            my $msg = "$sender was last seen in $row->{channel} $s ago, saying \"$content\"";
            $say->($msg);
        } else {
            $say->("sorry, i've never seen $sender here :(");
        }
    }
}

sub find_employee {
    my ($self, $pattern, $text, $cmd, $say, $sender) = @_;
    my %map = (
        agentzh => '章亦春',
        jianingy => '杨家宁',
        arthas => '谢昕',
        ywayne => '王熠',
        leiyh => '雷永华',
        highway => '周海维',
        carriezh => '张皛珏',
        tangch => 'cheng.tang',
        'whj' => '王惠军',
    );
    $text =~ s/$pattern//;
    $text =~ s/\n+//sg;
    if ($text) {
        $text = $map{$text} || $text;
        my $url = 'http://api.openresty.org/=/model/YahooStaff/~/' . $text;
        $url = encode('utf8', $url),
        ### OpenResty URL: $url
        my $res;
        eval {
            $res = $Resty->get(
                $url,
                { _op => 'contains', _limit => 3 }
            );
        };
        if ($@ =~ /Login required/i) {
            $Resty->login($self->resty_account, $self->resty_password);
            $res = $Resty->get(
                $url,
                { _op => 'contains', _limit => 3 }
            );
        }
        if (_ARRAY($res)) {
            my $s = res2table($res);
            $say->($s);
        } else {
            my @ans = (
                'sorry, not found...',
                'oops, i got nothing :(',
                'sigh...none obtained :/',
                '0 hits...',
            );
            my $ans = pick(\@ans);
            $say->("$sender: $ans");
        }
    }
}

sub punish_him {
    my ($self, $pattern , $text, $cmd, $say, $sender) = @_;
    my @craps = (
        "kills $sender",
        "throws $sender off the cliff",
        "slaps $sender around with a large trout",
        "slaps a large trout around a bit with $sender",
        "kicks $sender mercilessly",
        "hands a big bomb to $sender",
        "cuts off $sender\'s head",
    );

    my $s = pick(\@craps);
    $self->emote(
        channel => $self->channel,
        body => "$s.",
    );
}

sub reply_crap {
    my ($self, $pattern , $text, $cmd, $say, $sender) = @_;
    my @craps = (
        "yes, i'm aware of that :)",
        ";)",
        "why?",
        "^_^",
        "i see.",
        "really?",
        "hey!",
        "cool",
        ":P",
        "yo",
        "hiya",
    );
    warn "About to generating craps...\n";
    my $s = pick(\@craps);
    warn $s;
    $say->("$sender: $s");
}

sub html2text {
    my $html = shift;
    $html =~ s/<[^>]+>//g;
    $html =~ s/\&nbsp;/ /g;
    $html =~ s/\&lt;/</g;
    $html =~ s/\&gt;/>/g;
    $html =~ s/\&amp;/\&/g;
    $html;
}

sub guess_charset {
    my ($data, $charset) = @_;
    my @enc = qw( utf8 gbk Big5 Latin1 );
    warn "guess charset: $charset";
    for my $enc ($charset, @enc) {
        my $decoder = guess_encoding($data, $enc);
        if (ref $decoder) {
#            if ($enc ne 'ascii') {
#                print "line $.: $enc message found: ", $decoder->decode($s), "\n";
#            }
            my $enc = $decoder->name;
            $enc = $EncodingMap{$enc} || $enc;
            return $enc;
        }
    }
    return 'utf8';
}

sub res2table {
    my ($res) = @_;
    return '' if !defined $res or !@$res;
    my @keys = reverse sort grep { $_ ne 'id' } keys %{ $res->[0] };
    my @lines; # = join ' | ', map {
    #my $e = $_;
    #$e =~ s/_/ /g;
    #$e =~ s/\b(?:im|id)\b/uc($&)/eg;
    #$e =~ s/\b[A-Za-z]+\b/ucfirst($&)/eg;
    #$e;
    #} @keys;
    for my $line (@$res) {
        my @items;
        for my $key (@keys) {
            my $val = $line->{$key};
            if (!defined $val) { $val = '' }
            #$val = decode('utf8', $val);
            $val =~ s/^\+86-//g;
            $val =~ s/\&amp;/\&/g;
            push @items, $val;
        }
        push @lines, join ' | ', @items;
    }
    return join "\n", @lines;
}

1;

