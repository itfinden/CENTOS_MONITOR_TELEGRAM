#!/usr/bin/perl
#
# check-rbl
#
# Check if an IP is listed on most famous RBL.
#
# Exit code is 0 if not, 1 if listed.
#
# http://github.com/djinns/check-rbl
#
# Copyright (C) 2012 djinns@chninkel.net
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
 
####
# LIBS
####
use warnings;
use strict;
use Getopt::Long;
use Net::IP;
use Net::DNS;
 
####
# RBL
####
my @rbl=(
'aspews.ext.sorbs.net',
'ips.backscatterer.org',
'b.barracudacentral.org',
'l1.bbfh.ext.sorbs.net',
'l2.bbfh.ext.sorbs.net',
'bl.blocklist.de',
'list.blogspambl.com',
'cbl.anti-spam.org.cn',
'cblplus.anti-spam.org.cn',
'cblless.anti-spam.org.cn',
'cdl.anti-spam.org.cn',
'cbl.abuseat.org',
'bogons.cymru.com',
'tor.dan.me.uk',
'torexit.dan.me.uk',
'dnsblchile.org',
'rbl.dns-servicios.com',
'bl.drmx.org',
'dnsbl.dronebl.org',
'rbl.efnet.org',
'spamsources.fabel.dk',
'dnsbl.cobion.com',
'forbidden.icm.edu.pl',
'spamrbl.imp.ch',
'wormrbl.imp.ch',
'dnsbl.inps.de',
'rbl.interserver.net',
'mail-abuse.blacklist.jippg.org',
'dnsbl.kempt.net',
'bl.konstant.no',
'spamblock.kundenserver.de',
'ubl.lashback.com',
'spamguard.leadmon.net',
'dnsbl.madavi.de',
'bl.mailspike.net',
'z.mailspike.net',
'phishing.rbl.msrbl.net',
'spam.rbl.msrbl.net',
'relays.nether.net',
'unsure.nether.net',
'ix.dnsbl.manitu.net',
'psbl.surriel.com',
'dyna.spamrats.com',
'noptr.spamrats.com',
'spam.spamrats.com',
'rbl.schulte.org',
'exitnodes.tor.dnsbl.sectoor.de',
'backscatter.spameatingmonkey.net',
'bl.spameatingmonkey.net',
'bl.score.senderscore.com',
'korea.services.net',
'dnsbl.sorbs.net',
'dul.dnsbl.sorbs.net',
'http.dnsbl.sorbs.net',
'misc.dnsbl.sorbs.net',
'new.spam.dnsbl.sorbs.net',
'smtp.dnsbl.sorbs.net',
'socks.dnsbl.sorbs.net',
'spam.dnsbl.sorbs.net',
'web.dnsbl.sorbs.net',
'zombie.dnsbl.sorbs.net',
'bl.spamcop.net',
'zen.spamhaus.org',
'l1.spews.dnsbl.sorbs.net',
'l2.spews.dnsbl.sorbs.net',
'dnsrbl.swinog.ch',
'rbl2.triumf.ca',
'truncate.gbudb.net',
'dnsbl-1.uceprotect.net',
'dnsbl-2.uceprotect.net',
'dnsbl-3.uceprotect.net',
'virbl.dnsbl.bit.nl',
'dnsbl.zapbl.net',
'dnsbl.webequipped.com'
);
####
# VARS
####
my ($o_ip,$o_help,$o_quiet,$o_verbose);
 
####
# FUNCTIONS
####
 
# check_options
sub check_options {
    Getopt::Long::Configure ("bundling");
    GetOptions(
        'i:s'   => \$o_ip,              'ip:s'          => \$o_ip,
        'q'     => \$o_quiet,   'quiet'         => \$o_quiet,
        'v'     => \$o_verbose, 'verbose'       => \$o_verbose,
        'h'     => \$o_help,    'help'          => \$o_help
    );
 
    if (!defined($o_ip)||($o_help)) {
        usage();
        exit;
    }
}
 
# usage
sub usage {
    print <<"EOT";
Usage of $0
 
Required parameters:
        -i,--ip           The IP or subnet to check
        -q,--quiet        Quiet mode
        -v,--verbose  Verbose mode
 
        -h,--help       Show help
 
    Report bugs or ask for new options: https://github.com/DjinnS/check-rbl
 
EOT
}
 
# check rbl
sub check_rbl {
 
        my $reverse = $_[0];
        my $ip = $_[1];
        my $warn=0;
 
        foreach(@rbl) {
 
                my $query = $reverse . $_;
 
                my $res = Net::DNS::Resolver->new;
                my $set = $res->search($query);
 
                if ($set) {
                        if(!$o_quiet) { print $ip ." listado en ". $_ ." !\n"; }
                        $warn=1;
                } else {
                        if($o_verbose) { print $ip ." no listado en  ". $_ ." !\n"; }
                }
        }
 
        return $warn;
}
 
 
####
# MAIN
####
 
check_options();
 
my $ip= new Net::IP($o_ip);
my $warn=0;
 
if($ip) {
 
        if($ip->size() > 1) {
 
                ++$ip;
                do {
                        my $ip2 = new Net::IP($ip->ip());
                        $_ = $ip2->reverse_ip();
                        s/in\-addr\.arpa\.//gi;
                        $warn=check_rbl($_,$ip2->ip());
                } while (++$ip);
        }
 
        $_ = $ip->reverse_ip();
 
        s/in\-addr\.arpa\.//gi;
 
        my $reverse = $_;
 
        $warn=check_rbl($_,$ip->ip());
 
} else {
        print "Not a valid IP Address !\n";
}
 
if(!$warn) {
        if(!$o_quiet) { print "LIMPIO!\n"; }
}
 
exit($warn);
