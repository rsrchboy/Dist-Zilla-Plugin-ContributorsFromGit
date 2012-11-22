package Dist::Zilla::Plugin::ContributorsFromGit;

# ABSTRACT: Populate your 'CONTRIBUTORS' POD from the list of git authors

use Moose;
use namespace::autoclean;
use autobox::Core;
use List::AllUtils qw{ apply max uniq };
use Syntax::Keyword::Junction 'none';

use autodie 'system';
use IPC::System::Simple ( ); # explict dep for autodie system

use aliased 'Dist::Zilla::Stash::PodWeaver';

with
    'Dist::Zilla::Role::BeforeBuild',
    'Dist::Zilla::Role::RegisterStash',
    ;

# debugging...
#use Smart::Comments '###';

# all author names
# git log --format="%aN <%aE>" | sort | uniq
# all contributor
# git log --format="%cN <%cE>" | sort | uniq

# per-line stats, too; see
# http://codeimpossible.com/2011/12/16/Stupid-Git-Trick-getting-contributor-stats/

# XXX add PodWeaver stash if not found?
# XXX add git committers into the mix, too?
# XXX make zilla->authors filtering optional?

sub before_build {
    my $self = shift @_;

    ### get our stash, config...
    my $stash   = $self->zilla->stash_named('%PodWeaver');
    do { $stash = PodWeaver->new; $self->_register_stash('%PodWeaver', $stash) }
        unless defined $stash;
    my $config  = $stash->_config;
    my @authors = $self->zilla->authors->flatten;

    ### and get our list from git, filtering: "@authors"
    my @contributors = uniq sort
        grep  { none(@authors) eq $_ }
        apply { chomp                }
        `git log --format="%aN <%aE>"`
        ;

    my $i = 0;
    do { $config->{"Contributors.contributors[$i]"} = $_; $i++ }
        for @contributors;

    return;
}

__PACKAGE__->meta->make_immutable;
!!42;
__END__

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SEE ALSO

L<Pod::Weaver::Section::Contributor>

L<Dist::Zilla::Stash::PodWeaver>

=cut
