requires "Dist::Zilla" => "5.013";
requires "Dist::Zilla::Role::BeforeBuild" => "0";
requires "Dist::Zilla::Role::MetaProvider" => "0";
requires "Dist::Zilla::Role::RegisterStash" => "0";
requires "Dist::Zilla::Stash::PodWeaver" => "0";
requires "Encode" => "0";
requires "File::ShareDir::ProjectDistDir" => "0";
requires "File::Which" => "0";
requires "IPC::System::Simple" => "0";
requires "List::AllUtils" => "0";
requires "Path::Class" => "0";
requires "Reindeer" => "0.017";
requires "YAML::Tiny" => "0";
requires "aliased" => "0";
requires "autobox::Core" => "0";
requires "autobox::Junctions" => "0";
requires "autodie" => "0";
requires "perl" => "v5.10.0";
requires "utf8" => "0";

on 'test' => sub {
  requires "Directory::Scratch" => "0";
  requires "File::Spec" => "0";
  requires "File::chdir" => "0";
  requires "IO::Handle" => "0";
  requires "IPC::Open3" => "0";
  requires "Test::CheckDeps" => "0.010";
  requires "Test::DZil" => "0";
  requires "Test::Moose::More" => "0";
  requires "Test::More" => "0.94";
  requires "Test::TempDir" => "0";
  requires "lib" => "0";
  requires "strict" => "0";
  requires "warnings" => "0";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "6.30";
  requires "File::ShareDir::Install" => "0.03";
};

on 'develop' => sub {
  requires "Pod::Coverage::TrustPod" => "0";
  requires "Test::More" => "0";
  requires "Test::NoTabs" => "0";
  requires "Test::Pod" => "1.41";
  requires "Test::Pod::Coverage" => "1.08";
  requires "version" => "0.9901";
};
