package Dist::Zilla::Plugin::ContributorsFromGit;

# ABSTRACT: Populate your 'CONTRIBUTORS' POD from the list of git authors

use utf8;
use v5.10;

use Reindeer;
use Encode qw(decode_utf8);
use autobox::Core;
use File::Which 'which';
use List::AllUtils qw{ apply max uniq };
use Syntax::Keyword::Junction 'none';

use autodie 'system';
use IPC::System::Simple ( ); # explict dep for autodie system

use aliased 'Dist::Zilla::Stash::PodWeaver';

with
    'Dist::Zilla::Role::BeforeBuild',
    'Dist::Zilla::Role::RegisterStash',
    'Dist::Zilla::Role::MetaProvider',
    ;

# debugging...
#use Smart::Comments '###';

has contributor_list => (
    is      => 'lazy',
    isa     => 'ArrayRef[Str]',
    builder => sub {
        my $self = shift @_;
        my @authors = $self->zilla->authors->flatten;

        ### and get our list from git, filtering: "@authors"
        my @contributors = uniq
            map   { $self->author_emails->{$_} // $_    }
            grep  { $_ ne 'Your Name <you@example.com>' }
            grep  { none(@authors) eq $_                }
            apply { chomp; s/\s*\d+\s*//; $_ = decode_utf8($_) }
            `git shortlog -s -e`
            ;

        return \@contributors;
    },
);

=attr author_emails

This is an hash of additional emails that may be found from time to time in
git commit logs mapped back to the author's 'canonical' author email.
Generally speaking, the 'canonical email' will be the author's C<@cpan.org>
address, so that C<metacpan> may properly attribute contributions.

e.g.

    {
        'Chris Weyl <cweyl@alumni.drew.edu>' => 'Chris Weyl <rsrchboy@cpan.org>',
        'Chris Weyl <chris.weyl@wps.io>'     => 'Chris Weyl <rsrchboy@cpan.org>',
        ...
    }

Note that this attribute is *read-only*; B<please> fork and send a pull
request if you'd like to add additional mappings.  This is highly
encouraged. :)

=cut

has author_emails => (
    is       => 'lazy',
    isa      => HashRef[Str],
    init_arg => undef,

    builder => sub {

        state $mapping = {
            'Chris Weyl <rsrchboy@cpan.org>' => [
                'Chris Weyl <cweyl@alumni.drew.edu>',
                'Chris Weyl <cweyl@campusexplorer.com>',
                'Chris Weyl <chris.weyl@wps.io>',
                'Chris Weyl <cweyl@whitepointstarllc.com>',
            ],

            # here's where you'd add your mapping :)
        };

        my $_map_it = sub {
            my ($canonical, @alternates) = @_;

            return ( map { $_ => $canonical } @alternates );
        };

        state $map = {
            map { $_map_it->($_ => $mapping->{$_}->flatten) }
            $mapping->keys->flatten
        };

        return $map;
    },
);

sub before_build {
    my $self = shift @_;

    # skip if we can't find git
    unless (which 'git') {
        $self->log('The "git" executable has not been found');
        return;
    }

    # XXX we should also check here that we're in a git repo, but I'm going to
    # leave that for the git stash (when it's not vaporware)

    ### get our stash, config...
    my $stash   = $self->zilla->stash_named('%PodWeaver');
    do { $stash = PodWeaver->new; $self->_register_stash('%PodWeaver', $stash) }
        unless defined $stash;
    my $config       = $stash->_config;
    my @contributors = $self->contributor_list->flatten;

    my $i = 0;
    do { $config->{"Contributors.contributors[$i]"} = $_; $i++ }
        for @contributors;

    # add contributor names as stopwords
    $i = 0;
    my @stopwords = uniq
        apply { split / /        }
        apply { /^(.*) <.*$/; $1 }
        @contributors
        ;
    do { $config->{"StopWords.include[$i]"} = $_; $i++ }
        for @stopwords;

    return;
}

sub metadata {
    my $self = shift @_;
    my $list = $self->contributor_list;
    return @$list ? { 'x_contributors' => $list } : {};
}

__PACKAGE__->meta->make_immutable;
!!42;
__END__

=for :stopwords zilla BeforeBuild metacpan

=for Pod::Coverage before_build metadata

=head1 SYNOPSIS

    ; in your dist.ini
    [ContributorsFromGit]

    ; in your weaver.ini
    [Contributors]

=head1 DESCRIPTION

This plugin makes it easy to acknowledge the contributions of others by
populating a L<%PodWeaver|Dist::Zilla::Stash::PodWeaver> stash with the unique
list of all git commit authors reachable from the current HEAD.

=head1 OVERVIEW

On collecting the unique list of reachable commit authors from git, we search
and remove any git authors from the list of authors L<Dist::Zilla> knows
about.  We then look for a stash named C<%PodWeaver>; if we don't find one
then we create an instance of L<Dist::Zilla::Stash::PodWeaver> and register it
with our zilla instance.  Then we add the list of contributors (the filtered
git authors list) to the stash in such a way that
L<Pod::Weaver::Section::Contributors> can find them.

Note that you do not need to have the C<%PodWeaver> stash created; it will be
added if it is not found.  However, your L<Pod::Weaver> config (aka
c<weaver.ini>) must include the
L<Contributors|Pod::Weaver::Section::Contributors> section plugin.

This plugin runs during the L<BeforeBuild|Dist::Zilla::Role::BeforeBuild>
phase.

The list of contributors is also added to distribution metadata under the custom
C<x_contributors> key.

=for :stopwords shortlog committer

If you have duplicate contributors because of differences in committer name
or email you can use a C<.mailmap> file to canonicalize contributor names
and emails.  See L<git help shortlog|git-shortlog(1)> for details.

=head1 SEE ALSO

L<Pod::Weaver::Section::Contributors>

L<Dist::Zilla::Stash::PodWeaver>

=cut
