# Always be safe
use strict;
use warnings;

# Use the module
use Mail::IMAPClient;
use Sys::Hostname;
use Getopt::Std;

sub usage()
{
  print STDERR << "EOF";
-u : IMAP Username
-p : IMAP Password
EOF
  exit;
}

my %options=();
getopts("u:p:F:", \%options) or usage();

my $mail_password = $options{p} || usage();
my $mail_user = $options{u} || usage();

my $imap = Mail::IMAPClient->new(
  Server   => 'imap.gmail.com',
  User     => $mail_user,
  Password => $mail_password,
  Port     => 993,
  Ssl      => 1,
 )
       or die "IMAP Failure: $@";

$imap->State(Mail::IMAPClient::Connected());

if ( !-d 'mail' ) {
  mkdir('mail',0777);
}

foreach my $box (qw( INBOX )) {

  if ( !-d "mail/$box" ) {
    mkdir("mail/$box",0777);
  }

  if ( !-d "mail/$box/cur" ) {
    mkdir("mail/$box/cur",0777);
  }

  if ( !-d "mail/$box/new" ) {
    mkdir("mail/$box/new",0777);
  }

  if ( !-d "mail/$box/tmp" ) {
    mkdir("mail/$box/tmp",0777);
  }

  $imap->select($box)
       or die "IMAP Select Error: $!";

  my @msgs = $imap->search('ALL')
    or die "Couldn't get all messages\n";

  foreach my $msg (@msgs) {
    my $filename = time . "." . int(rand(10000)) . "." . hostname();
    open my $fh, ">>mail/$box/cur/$filename"
      or die("Open File Error: $!");

    $imap->message_to_file($fh, $msg);

    close $fh
      or die("Formail Close Pipe Error: $!");
  }

  $imap->close($box);
}

$imap->logout();
