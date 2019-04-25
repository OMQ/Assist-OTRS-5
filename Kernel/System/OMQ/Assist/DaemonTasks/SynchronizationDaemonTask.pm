# --
# Kernel/System/OMQ/Assist/DaemonTasks/SynchronizationDaemonTask.pm - Daemon Cron Task to OTRS with OMQ Backend
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

package Kernel::System::OMQ::Assist::DaemonTasks::SynchronizationDaemonTask;

use strict;
use warnings;

use JSON;

our @ObjectDependencies = (
    'Kernel::System::OMQ::Assist::Tasks::QueueSynchronization',
    'Kernel::System::OMQ::Assist::Tasks::UserSynchronization'
);

=head1 NAME

Kernel::System::OMQ::Assist::DaemonTasks::SynchronizationDaemonTask - Daemon Cron Task to synchronize OTRS with OMQ Backend

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

Run queue sync and user sync

=cut

sub Run {
    my ($Self) = @_;

    # run queue sync
    my $QueueSyncTask = $Kernel::OM->Get('Kernel::System::OMQ::Assist::Tasks::QueueSynchronization');
    $QueueSyncTask->Run();

    # run user sync
    my $UserSyncTask = $Kernel::OM->Get('Kernel::System::OMQ::Assist::Tasks::UserSynchronization');
    $UserSyncTask->Run();

    return $Self;
}

1;

=back
