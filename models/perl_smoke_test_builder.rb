require "versionomy"

###
    
class PerlSmokeTestBuilder < Jenkins::Tasks::Builder

    attr_accessor :enabled, :distro_url
    attr_accessor :scripts
    attr_accessor :ssh_host, :ssh_login

    display_name "Run Smoke Tests on Perl Application" 

    # Invoked with the form parameters when this extension point
    # is created from a configuration screen.
    def initialize(attrs = {})
        @attrs = attrs
        @enabled = attrs["enabled"]
        @distro_url = attrs["distro_url"]
        @paths = attrs["scripts"] || ""
        @ssh_host = attrs["ssh_host"]
        @ssh_login = attrs["ssh_login"]

    end

    ##
    # Runs before the build begins
    #
    # @param [Jenkins::Model::Build] build the build which will begin
    # @param [Jenkins::Model::Listener] listener the listener for this build.
    def prebuild(build, listener)
      # do any setup that needs to be done before this build runs.
    end

    ##
    # Runs the step over the given build and reports the progress to the listener.
    #
    # @param [Jenkins::Model::Build] build on which to run this step
    # @param [Jenkins::Launcher] launcher the launcher that can run code on the node running this build
    # @param [Jenkins::Model::Listener] listener the listener for this build.
    def perform(build, launcher, listener)

      # actually perform the build step

        env = build.native.getEnvironment()
        job = build.send(:native).get_project.name

        # start smoke tests
        if @enabled == true 

            listener.info "running smoke tests on remote host: #{@ssh_host}"

            listener.info "download distributive #{distro_url}"
            cmd = []
            cmd << "export LC_ALL=#{env['LC_ALL']}" unless ( env['LC_ALL'].nil? || env['LC_ALL'].empty? )
            cmd << "ssh #{@ssh_login}@#{@ssh_host}"
            cmd << "rm -rf .perl_smoke_test/"
            cmd << "mkdir .perl_smoke_test/"
            cmd << "cd .perl_smoke_test/"
            cmd << "wget #{@distro_url}"
            listener.info "ssh command: #{cmd.join(' && ')}"
            build.abort unless launcher.execute("bash", "-c", cmd.join(' && '), { :out => listener } ) == 0

            listener.info "unpack distributive"
            cmd = []
            dist_name = @distro_url.split('/').last
            dist_dir = dist_name.sub('.tar.gz','')
            listener.info "distro_url: #{@distro_url}"
            listener.info "dist_name: #{dist_name}"
            listener.info "dist_dir: #{dist_dir}"
            cmd << "export LC_ALL=#{env['LC_ALL']}" unless ( env['LC_ALL'].nil? || env['LC_ALL'].empty? )
            cmd << "ssh #{@ssh_login}@#{@ssh_host}"
            cmd << "cd .perl_smoke_test/"
            cmd << "tar -xzf #{dist_name}"
            cmd << "cd #{dist_dir}"
            build.abort unless launcher.execute("bash", "-c", cmd.join(' && '), { :out => listener } ) == 0

            listener.info "run application tests"
            cmd = []
            cmd << "export LC_ALL=#{env['LC_ALL']}" unless ( env['LC_ALL'].nil? || env['LC_ALL'].empty? )
            cmd << "export PERL5LIB=#{env['PERL5LIB']}" unless ( env['PERL5LIB'].nil? || env['PERL5LIB'].empty? )
            cmd << "ssh #{@ssh_login}@#{@ssh_host}"
            cmd << "cd .perl_smoke_test/"
            cmd << "cd #{dist_dir}"
            cmd << "eval $(perl -Mlocal::lib=./cpanlib)"
            cmd << "perl Build.PL"
            cmd << "./Build"
            cmd << "./Build test"
            build.abort unless launcher.execute("bash", "-c", cmd.join(' && '), { :out => listener } ) == 0

        end # if @enabled == true

    end

end
