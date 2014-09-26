# perl-smoke-test-plugin
run smoke tests against perl application distributive:
 - check if all dependencies are met
 - check compilation / syntax errors on given scripts

# what it does

 1) Connect to remote host with gien ssh login using ssh public-key authentication schema
 2) Upload distributive to host
 3)  Unpack it
 4) Run standard perl Build.PL/Makefile.PL cycle to execute unit tests and check prerequisites
 5) So - If anything goes wrong you know it in good time, before release is happened!



# plugin interface
 
![layout](https://raw.github.com/melezhik/perl-smoke-test-plugin/master/images/layout.png "layout")


# last stable release

- [0.0.3](http://repo.jenkins-ci.org/releases/org/jenkins-ci/ruby-plugins/perl-smoke-test/0.0.3/perl-smoke-test-0.0.3.hpi)

# prerequisites

- curl
- perl

# to-do list
- support for ExtUtils::MakeMaker projects ( currently only Module::Build supported )




