use Test::More;

plan( skip_all => "Author tests not required for installation" )
  unless $ENV{AUTOMATED_TESTING} or $ENV{RELEASE_TESTING};

eval "use Test::YAML::Meta";
plan skip_all => "Test::YAML::Meta required for testing Meta.yml file" if $@;

meta_yaml_ok();