# --
# Kernel/System/OMQ/Assist/Tasks/QueueSynchronization.pm - Daemon Cron Task to synchronize queues with OMQ Backend
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# Extensions Copyright © 2010-2017 OMQ GmbH, http://www.omq.de
#
# written/edited by:
# * info(at)omq(dot)de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::OMQ::Assist::Tasks::QueueSynchronization;

use strict;
use warnings;

use JSON;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Queue',
    'Kernel::System::OMQ::Assist::Util',
    'Kernel::System::OMQ::Assist::Backend'
);

=head1 NAME

Kernel::System::OMQ::Assist::Tasks::QueueSynchronization - Daemon Cron Task to synchronize queues with OMQ Backend

=head1 SYNOPSIS

Called every 5 minutes by Daemon

=cut

=over

=item new()

Constructor

=cut

sub new {
    my ($Type) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=item Install()

Run Task, send queue to OMQ backend

=cut

sub Run {
    my ($Self) = @_;

    my $QueueObject = $Kernel::OM->Get('Kernel::System::Queue');
    my $OmqUtil     = $Kernel::OM->Get('Kernel::System::OMQ::Assist::Util');
    my $OmqBackend  = $Kernel::OM->Get('Kernel::System::OMQ::Assist::Backend');

    $OmqUtil->Log(
        Priority => 'notice',
        Message  => "OMQ assist synchronize queues.\n"
    );

    my @JsonCategories = ();
    my %Queues         = $QueueObject->QueueList( Valid => 1 );
    my %QueueIDs       = reverse %Queues;

    for my $Key ( sort { $a <=> $b } keys %Queues ) {

        my $QueueID = $Key;
        my $Name    = $Queues{$Key};

        # split queue into sub queues
        my @Sub = split( /::/, $Name );

        # get id of parent queue
        my $ParentID;
        my $QueueName = pop(@Sub);
        my $Parent = join( '::', @Sub );

        if ( $Parent && $QueueIDs{$Parent} ) {
            $ParentID = int( $QueueIDs{$Parent} );
        }

        # generate JSON
        my $JsonCategory = {
            id     => int($QueueID),
            name   => $QueueName,
            parent => $ParentID
        };

        # add to array
        push( @JsonCategories, $JsonCategory );
    }

    if ( !@JsonCategories ) {
        return;
    }

    $OmqBackend->SendRequest(
        URL  => '/api/categories/external/sync?source=OTRS',
        Type => 'POST',
        Body => \@JsonCategories
    );

    $OmqUtil->Log(
        Priority => 'notice',
        Message  => "OMQ assist queues synchronized.\n"
    );

    return $Self;
}

1;

=back
