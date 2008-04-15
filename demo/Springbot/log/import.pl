use strict;
use warnings;

use Params::Util qw(_HASH);
use WWW::OpenResty::Simple;
use Getopt::Std;
use Date::Calc qw(Add_Delta_Days);

my %opts;
getopts('u:p:', \%opts) or
    die "Usage: ./import.pl -u <user> -p <password> [pigin_log_dir]\n";

my $user = $opts{u} or die "No -u specified.\n";
my $password = $opts{p} or die "No -p specified.\n";

my $dir = shift || '/home/agentz/.purple/logs/irc/agentzh@10.62.136.8/#eeee.chat';
my @files = glob "$dir/2008-03-17*.txt";

my $resty = WWW::OpenResty::Simple->new(
    { server => 'resty.eeeeworks.org' }
);
$resty->login($user, $password);
$resty->delete('/=/model/IrcLog/~/~');

my $inserted = 0;
for my $file (@files) {
    warn "Processing log file $file...\n";
    my ($year, $month, $day);
    if ($file =~ /(\d{4})-(\d{2})-(\d{2})/) {
        ($year, $month, $day) = ($1, $2, $3);
    } else {
        die "Can't get year-month-day from the log file name $file\n";
    }
    open my $in, $file or
        die "Can't open $file for reading: $!\n";
    my @rows;
    my $last_flag;
    while (<$in>) {
        if (/^\((.*?)\) (\w+): (.*)/) {
            my $time = $1;
            my $sender = $2;
            my $content = $3;

            my $cur_flag;
            if ($time =~ /PM/) {
                $cur_flag = 'PM';
            } else {
                $cur_flag = 'AM';
            }
            if (!$last_flag) { $last_flag = $cur_flag; }
            if ($cur_flag ne $last_flag) {
                if ($last_flag eq 'PM' and $cur_flag eq 'AM') {
                    ($year, $month, $day) =
                        Add_Delta_Days($year, $month, $day, 1);
                    warn "\n$year-$month-$day\n";
                }
                $last_flag = $cur_flag;
            }
            my $sent_on = "$year-$month-$day $time";
            my $row = {
                channel => '#eeee',
                sender => $sender,
                content => $content,
                type => 'msg',
                sent_on => $sent_on,
            };
            push @rows, $row;
            if (@rows % 20 == 0) {
                $inserted += insert_rows(\@rows);
                @rows = ();
                print STDERR "\t$inserted";
            }
        }
    }
    if (@rows) {
        $inserted += insert_rows(\@rows);
    }
    print STDERR "\n$inserted row(s) inserted.\n";
    close $in;
}
print STDERR "\nFor total $inserted row(s) inserted.\n";

sub insert_rows {
    my $rows = shift;
    my $res = $resty->post('/=/model/IrcLog/~/~', $rows);
    return 0 unless _HASH($res);
    return $res->{rows_affected} || 0;
    print STDERR "\t$inserted" if $inserted % 20 == 0;
}

