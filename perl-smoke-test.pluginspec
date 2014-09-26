Jenkins::Plugin::Specification.new do |plugin|
  plugin.name = "perl-smoke-test"
  plugin.display_name = "Perl Smoke Test Plugin"
  plugin.version = '0.0.3'
  plugin.description = 'runs smoke tests against perl application distributive on remote host'

  # You should create a wiki-page for your plugin when you publish it, see
  plugin.url = 'https://github.com/melezhik/perl-smoke-test-plugin'

  # The first argument is your user name for jenkins-ci.org.
  plugin.developed_by "melezhik", "Alexey Melezhik <melezhik@gmail.com>"

  # This specifies where your code is hosted.
  plugin.uses_repository :github => "melezhik/perl-smoke-test-plugin"

  # This is a required dependency for every ruby plugin.
  plugin.depends_on 'ruby-runtime', '0.10'

  # This is a sample dependency for a Jenkins plugin, 'git'.
  #plugin.depends_on 'git', '1.1.11'
end

