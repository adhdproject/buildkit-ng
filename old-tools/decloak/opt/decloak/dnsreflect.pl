#!/usr/bin/perl
###############

use Net::DNS::Nameserver;
use DBD::Pg;

use POSIX ":sys_wait_h";

use strict;
use warnings;

# Configure the user ID to run as (must start as root)
my $user = 1000;

# Configure the interfaces and ports

# This address must have port 53 available and be the DNS server
# for the wildcard subdomain (spy.decloak.net). Changing this
# domain also means updating the Java, Flash, and PHP.

my $serv = '0.0.0.0';

# You need :53 on the wildcard domain and :5353 on the IP running the web site
my $bind = [ [$serv, 53], ['0.0.0.0', 5353] ];

# You need :53530 TCP on the IP running the web site
my $tcps = [ ['0.0.0.0', 53530], ['0.0.0.0', 843] ];

# Wildcard subdomain we handle DNS for
my $dom  = "spy.decloak.net";

# Configure postgres credentials
my $db_name = "decloak";
my $db_user = "decloakuser";
my $db_pass = "adhd";
my $dbh;

my $opts = {
	AutoCommit => 1,
	RaiseError => 0,
};

# Escape the $dom var to be a valid regex
$dom =~ s/\./\\\./g;

foreach my $c ( @{$bind} ) {
	if (! fork()) {
		Launch($c->[0], $c->[1]);
		exit(0);
	}	
}

foreach my $c ( @{$tcps} ) {
	if (! fork()) {
		LaunchTCP($c->[0], $c->[1]);
		exit(0);
	}	
}

exit(0);

# This table must already exist
##
# Table "public.requests"
#  Column |         Type          | Modifiers
# --------+-----------------------+-----------
# cid    | character(32)         |
# type   | character varying(16) |
# eip    | character varying(16) |
# iip    | character varying(16) |
# dip    | character varying(16) |
# stamp  | timestamp             |
##

sub reply_handler {
	my ($qname, $qclass, $qtype, $peerhost) = @_;
	my ($rcode, @ans, @auth, @add);

	if ($qname =~ m/^([a-z0-9]{32})\.(\w+)\.(\d+\.\d+\.\d+\.\d+)\.(\d+\.\d+\.\d+\.\d+)\.$dom/) {
		# print "$peerhost > $qname (MATCH)\n";
		my ($cid, $type, $eip, $iip, $dip) = ($1, $2, $3, $4, $peerhost);
		my $sth = $dbh->prepare("INSERT INTO requests values (?, ?, ?, ?, ?, now())");
		$sth->execute($cid, $type, $eip, $iip, $dip);
		$sth->finish();
	}else{
		# print "$peerhost > $qname (NO MATCH)\n";
	}
         
         if ($qtype eq "A") 
         {
             my ($ttl, $rdata) = (1, $peerhost);
             push @ans, Net::DNS::RR->new("$qname $ttl $qclass A $rdata");
             $rcode = "NOERROR";
         } 
         elsif ($qtype eq "PTR") {
             my ($ttl, $rdata) = (1, $peerhost);
             push @ans, Net::DNS::RR->new("$qname $ttl $qclass A $rdata");
             $rcode = "NOERROR";              
         } 
         else {
             my ($ttl, $rdata) = (1, $peerhost);
             push @ans, Net::DNS::RR->new("$qname $ttl $qclass A $rdata");
             $rcode = "NOERROR";            
         }
         
         # mark the answer as authoritive (by setting the 'aa' flag
         return ($rcode, \@ans, \@auth, \@add, { aa => 1 });
}

sub Launch {

my $host = shift();
my $port = shift();

$0 .= " ($host:$port)";
 
$dbh = DBI->connect("DBI:Pg:dbname=$db_name", $db_user, $db_pass, $opts) || die "Couldn't connect to database: " . DBI->errstr;

my $ns = Net::DNS::Nameserver->new(
    LocalPort    => $port,
    LocalAddr    => $host,
    ReplyHandler => \&reply_handler,
    Verbose      => 0,
);


$<= $> = $user;

 
if ($ns) {
	$ns->main_loop;
} else {
   die "Couldn't create nameserver object\n";
}

}

sub LaunchTCP {

my $host = shift();
my $port = shift();

$0 .= " TCP ($host:$port)";
 
my $srv =  IO::Socket::INET->new( 
	'Proto'     => 'tcp',
	'LocalPort' => $port,
	'LocalAddr' => $host,
	'Listen'    => 5,
	'Reuse'     => 1
);

die unless $srv;

$<= $> = $user;

while (my $cli = $srv->accept()) {

	my $kid = 0;
	
	# Clean zombies
    do {
		$kid = waitpid(-1, WNOHANG);
    } while $kid > 0;
		
	if(! fork()) {
		while(1) {
			my $sel = IO::Select->new($cli);
			$cli->autoflush(1);
			if ($sel->can_read(5)) {
				my $buf = "";
				my $len = sysread($cli, $buf, 16384);
				
				if ($len && $buf =~ m/^([a-z0-9]{32}):(.*)/i) {
					my $cid = $1;
					my $eip = $2;
					chomp($eip);

					$dbh = DBI->connect("DBI:Pg:dbname=$db_name", $db_user, $db_pass, $opts) || die "Couldn't connect to database: " . DBI->errstr;
					my $sth = $dbh->prepare("INSERT INTO requests values (?, ?, ?, ?, ?, now())");
					$sth->execute($cid, 'socket', $eip, '0.0.0.0', $cli->peerhost);
					$sth->finish();
					print $cli ($cli->peerhost . "\x00");
					last;
				}
				
				if($len && $buf eq "<policy-file-request/>\x00") {
					print $cli "<cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"*\" /></cross-domain-policy>\x00";
				}
				
				if(!$len || length($buf) == 0) {
					last;
				}
			}
		}
		$cli->close();
		exit(0);
	}
}

}
