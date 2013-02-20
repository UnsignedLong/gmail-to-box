# Always be safe
use strict;
use warnings;

# Use the module
use Mail::IMAPClient;
use IO::Socket::SSL;
use Sys::Hostname;

 my $imap = Mail::IMAPClient->new(
   Server   => 'imap.gmail.com',
   User     => 'user.name@gmail.com',
   Password => 'foobar',
   Port     => 993,
   Ssl      => 1,
  )
        or die "IMAP Failure: $@";

 $imap->State(Mail::IMAPClient::Connected());

 foreach my $box qw( INBOX ) {

   $imap->select($box)
        or die "IMAP Select Error: $!";

   my @msgs = $imap->search('ALL')
     or die "Couldn't get all messages\n";

   foreach my $msg (@msgs) {
     my $filename = time . "." . int(rand(10000)) . "." . hostname();
     open my $fh, ">>mail/$filename"
       or die("Open File Error: $!");

     $imap->message_to_file($fh, $msg);

     close $fh
       or die("Formail Close Pipe Error: $!");
   }

   $imap->close($box);
 }

 $imap->logout();
