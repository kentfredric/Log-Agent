###########################################################################
# $Id: Mail.pm,v 1.1 2002/04/25 05:38:47 wendigo Exp $
###########################################################################
#
# Log::Agent::Driver::Mail
#
# RCS Revision: $Revision: 1.1 $
# Date: $Date: 2002/04/25 05:38:47 $
#
# Copyright (C) 2002 Mark Rogaski, mrogaski@cpan.org; all rights reserved.
#
# See the README file included with the
# distribution for license information.
#
# $Log: Mail.pm,v $
# Revision 1.1  2002/04/25 05:38:47  wendigo
# Initial revision
#
#
###########################################################################

package Log::Agent::Driver::Mail;

use strict;
use Mail::Mailer;
require Log::Agent::Driver;

use vars qw(@ISA);
@ISA = qw(Log::Agent::Driver);

###########################################################################
#
# Public Methods
#
###########################################################################

#
# make -- driver constructor
#
sub make {
    my $self = bless {
        prefix     => '',
        to         => (getpwuid $<)[0],
        cc         => '',
        bcc        => '',
        subject    => '',
        from       => '',
        priority   => '',
        'reply-to' => ''
    }, shift;

    my (%args) = @_;
    
    foreach my $key (keys %args) {
        if ($key =~ /^-(to|cc|bcc|prefix|subject|from|priority|reply-to)$/) {
            $self->{$1} = $args{$key};
        } else {
            use Carp;
            croak "invalid argument: $key";
        }
    }

    $self->_init($self->{prefix}, 0);

    return $self;
}

#
# chan_eq -- not much of anything at the moment
#
sub chan_eq {
    my($self, $chan0, $chan1) = @_;
    return $chan0 eq $chan1;
}

#
# write -- send a message to the channel
#
sub write {
    my($self, $chan, $prio, $mesg) = @_;

    my(%headers);
    foreach my $hdr (qw( to cc bcc subject from priority reply-to )) {
        $headers{ucfirst($hdr)} = $self->{$hdr} unless $self->{$hdr} eq '';
    }

    my $mailer = Mail::Mailer->new;
    $mailer->open(\%headers);
    print $mailer $mesg, "\n";
    $mailer->close;
}

#
# prefix_msg -- add prefix
#
sub prefix_msg {
    my($self, $str) = @_;
    return ($self->{prefix} ? $self->{prefix} . ' ' : '') . $str;
}

__END__

=head1 NAME

Log::Agent::Driver::Mail - email driver for Log::Agent

=head1 SYNOPSIS

 use Log::Agent;
 require Log::Agent::Driver::Mail;

 my $driver = Log::Agent::Driver::Mail->make(
     -to      => 'oncall@example.org',
     -cc      => [ qw( noc@example.org admin@example,net ) ],
     -subject => "ALERT! ALERT!",
 );
 logconfig(-driver => $driver);

=head1 DESCRIPTION

This driver maps the logxxx() calls to email messages.  Each call generates
a separate email message.  The Mail::Mailer module is required.

=head1 CONSTRUCTOR

=head2 B<make OPTIONS>

The OPTIONS argument is a hash with the following keys:

=over 8

=item B<-prefix>

An optional prefix for the message body.

=item B<-to>

The destination addresses, may be a scalar containing a valid email address
or a reference to an array of addresses.

=item B<-reply-to>

The reply-to addresses, may be a scalar containing a valid email address
or a reference to an array of addresses.

=item B<-from>

The source address, must be a scalar containing a valid email address.

=item B<-subject>

The subject line of the email message.

=item B<-cc>

The carbon copy addresses, may be a scalar containing a valid email address
or a reference to an array of addresses.

=item B<-bcc>

The blind carbon copy addresses, may be a scalar containing a valid email
address or a reference to an array of addresses.

=item B<-priority>

The priority level for the email message.  This is NOT related to the logging
priority.

=item B<-to>

The destination addresses, may be a scalar containing a valid email address
or a reference to an array of addresses.

=back

=head1 NOTES

Thanks to Shirley Wang for the idea for this module.

=head1 AUTHOR

Mark Rogaski E<lt>mrogaski@pobox.comE<gt>

=head1 LICENSE

Copyright (C) 2002 Mark Rogaski; all rights reserved.

See L<Log::Agent(3)> or the README file included with the distribution for
license information.

=head1 SEE ALSO

L<Mail::Mailer>, L<Log::Agent::Driver(3)>, L<Log::Agent(3)>.



