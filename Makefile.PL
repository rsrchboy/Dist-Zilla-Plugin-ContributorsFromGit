
use strict;
use warnings;

use 5.006;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Populate your 'CONTRIBUTORS' POD from the list of git authors",
  "AUTHOR" => "Chris Weyl <cweyl\@alumni.drew.edu>",
  "BUILD_REQUIRES" => {
    "Directory::Scratch" => 0,
    "File::Find" => 0,
    "File::Temp" => 0,
    "File::chdir" => 0,
    "Path::Class" => 0,
    "Test::DZil" => 0,
    "Test::More" => "0.88",
    "Test::TempDir" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Dist-Zilla-Plugin-ContributorsFromGit",
  "EXE_FILES" => [],
  "LICENSE" => "lgpl",
  "NAME" => "Dist::Zilla::Plugin::ContributorsFromGit",
  "PREREQ_PM" => {
    "Dist::Zilla::Role::BeforeBuild" => 0,
    "Dist::Zilla::Role::MetaProvider" => 0,
    "Dist::Zilla::Role::RegisterStash" => 0,
    "Dist::Zilla::Stash::PodWeaver" => 0,
    "File::Which" => 0,
    "IPC::System::Simple" => 0,
    "List::AllUtils" => 0,
    "Moose" => 0,
    "MooseX::AttributeShortcuts" => "0.015",
    "Syntax::Keyword::Junction" => 0,
    "aliased" => 0,
    "autobox::Core" => 0,
    "autodie" => 0,
    "namespace::autoclean" => 0
  },
  "VERSION" => "0.004",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



