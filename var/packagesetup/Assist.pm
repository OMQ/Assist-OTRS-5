# --
# Copyright (C) 2010-2017 OMQ GmbH, http://www.omq.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package var::packagesetup::Assist;    ## no critic

use strict;
use warnings;

use utf8;

our @ObjectDependencies = (
    'Kernel::System::Group',
    'Kernel::System::Queue',
    'Kernel::System::StandardTemplate',
    'Kernel::System::SysConfig',
);

=head1 NAME

Assist.pm - code to execute during package installation

=head1 SYNOPSIS

All code to execute during package installation

=head1 PUBLIC INTERFACE

=over 4

=cut

=item new()

create an object

    use Kernel::System::ObjectManager;
    local $Kernel::OM = Kernel::System::ObjectManager->new();
    my $CodeObject    = $Kernel::OM->Get('var::packagesetup::Assist');

=cut

sub new {
    my ($Type) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # rebuild ZZZ* files
    $Kernel::OM->Get('Kernel::System::SysConfig')->WriteDefault();

    # define the ZZZ files
    my @ZZZFiles = (
        'ZZZAAuto.pm',
        'ZZZAuto.pm',
    );

    # disable redefine warnings in this scope
    {
        # nofilter(TidyAll::Plugin::OTRS::Perl::PerlCritic)
        no warnings 'redefine';

        # reload the ZZZ files (mod_perl workaround)
        for my $ZZZFile (@ZZZFiles) {

            PREFIX:
            for my $Prefix (@INC) {
                my $File = $Prefix . '/Kernel/Config/Files/' . $ZZZFile;
                next PREFIX if !-f $File;
                do $File;
                last PREFIX;
            }
        }
    }

    # make sure to use a new config object
    $Kernel::OM->ObjectsDiscard(
        Objects => ['Kernel::Config'],
    );

    return $Self;
}

=item CodeInstall()

run the code install part

    my $Result = $CodeObject->CodeInstall();

=cut

sub CodeInstall {
    my ($Self) = @_;

    $Self->_InstallOmqAssist();

    return 1;
}

=item CodeReinstall()

run the code reinstall part

    my $Result = $CodeObject->CodeReinstall();

=cut

sub CodeReinstall {
    my ($Self) = @_;

    $Self->_InstallOmqAssist();

    return 1;
}

=item CodeUpgrade()

run the code upgrade part

    my $Result = $CodeObject->CodeUpgrade();

=cut

sub CodeUpgrade {
    return 1;
}

=item CodeUninstall()

run the code uninstall part

    my $Result = $CodeObject->CodeUninstall();

=cut

sub CodeUninstall {
    my ($Self) = @_;

    $Self->UninstallOmqAssist();

    return 1;
}

=item _InstallOmqAssist()

Install OMQ assist for OTRS.

=cut

sub _InstallOmqAssist {
    my ($Self) = @_;

    $Self->_AddOmqGroups();

    return 1;
}

=item _UninstallOmqAssist()

Uninstall OMQ assist for OTRS.

=cut

sub _UninstallOmqAssist {
    my ($Self) = @_;

    return 1;
}

=item _AddOmqGroups()

Checks if groups already exist, and creates if not.

=cut

sub _AddOmqGroups {
    my $GroupObject = $Kernel::OM->Get('Kernel::System::Group');

    # create omq-admin group
    if ( !$GroupObject->GroupLookup( Group => 'omq-admin' ) ) {
        $GroupObject->GroupAdd(
            Name    => 'omq-admin',
            Comment => 'Group for OMQ assist Administration',
            ValidID => 1,
            UserID  => 1
        );
    }

    # create omq-editors group
    if ( !$GroupObject->GroupLookup( Group => 'omq-editors' ) ) {
        $GroupObject->GroupAdd(
            Name    => 'omq-editors',
            Comment => 'Group for OMQ assist Editors',
            ValidID => 1,
            UserID  => 1
        );
    }

    my $UsersGroupId  = $GroupObject->GroupLookup( Group => 'omq-users' );
    my $AgentsGroupId = $GroupObject->GroupLookup( Group => 'omq-agents' );

    # check if group omq-users exists, and rename to omq-agents
    if ($UsersGroupId) {
        $GroupObject->GroupUpdate(
            ID      => $UsersGroupId,
            Name    => 'omq-agents',
            Comment => 'Group for OMQ assist agents',
            ValidID => 1,
            UserID  => 1
        );
    }
    elsif ( !$AgentsGroupId ) {
        $GroupObject->GroupAdd(
            Name    => 'omq-agents',
            Comment => 'Group for OMQ assist agents',
            ValidID => 1,
            UserID  => 1
        );
    }

    return 1;
}

1;

=back

=head1 TERMS AND CONDITIONS

This software is part of the OTRS project (L<http://otrs.org/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (AGPL). If you
did not receive this file, see L<http://www.gnu.org/licenses/agpl.txt>.

=cut
