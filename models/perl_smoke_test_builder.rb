###
    
class PerlSmokeTestBuilder < Jenkins::Tasks::Builder

    attr_accessor :enabled, :distro_url
    attr_accessor :paths
    attr_accessor :ssh_host, :ssh_login
    attr_accessor :verbosity_type, :catalyst_debug

    display_name "Run Smoke Tests on Perl Application" 

    # Invoked with the form parameters when this extension point
    # is created from a configuration screen.
    def initialize(attrs = {})
        @attrs = attrs
        @enabled = attrs["enabled"]
        @distro_url = attrs["distro_url"]
        @paths = attrs["paths"] || ""
        @ssh_host = attrs["ssh_host"]
        @ssh_login = attrs["ssh_login"]
        @verbosity_type = attrs["verbosity_type"]
        @catalyst_debug = attrs["catalyst_debug"]

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

            dist_name = @distro_url.split('/').last
            dist_dir = dist_name.sub('.tar.gz','')

            listener.info "download distributive #{distro_url}"
            listener.info "distro_url: #{@distro_url}"
            listener.info "dist_name: #{dist_name}"
            listener.info "dist_dir: #{dist_dir}"

            if ( env['LC_ALL'].nil? || env['LC_ALL'].empty? )
                ssh_cmd = "ssh #{@ssh_login}@#{@ssh_host}"
            else
                ssh_cmd = "export LC_ALL=#{env['LC_ALL']} ssh #{@ssh_login}@#{@ssh_host}"
            end

            cmd = []
            cmd << "rm -rf .perl_smoke_test/"
            cmd << "mkdir .perl_smoke_test/"
            cmd << "cd .perl_smoke_test/"
            cmd << "curl -f #{@distro_url} -o #{dist_name}"
            listener.info "ssh command: #{ssh_cmd} '#{cmd.join(' && ')}'"
            build.abort unless launcher.execute("bash", "-c", "#{ssh_cmd} '#{cmd.join(' && ')}'", { :out => listener } ) == 0

            listener.info "unpack distributive"
            cmd = []
            cmd << "cd .perl_smoke_test/"
            cmd << "tar -xzf #{dist_name}"
            cmd << "cd #{dist_dir}"
            listener.info "ssh command: #{ssh_cmd} '#{cmd.join(' && ')}'"
            build.abort unless launcher.execute("bash", "-c", "#{ssh_cmd} '#{cmd.join(' && ')}'", { :out => listener } ) == 0

            listener.info "run application tests"
            cmd = []
            cmd << "cd .perl_smoke_test/"
            cmd << "cd #{dist_dir}"
            if ( env['PERL5LIB'].nil? || env['PERL5LIB'].empty? )
                cmd << "export PERL5LIB=./cpanlib/lib/perl5" 
            else
                cmd << "export PERL5LIB=./cpanlib/lib/perl5:#{env['PERL5LIB']}" 
            end
            cmd << "perl Build.PL"
            cmd << "./Build"
            test_verbose = ''
            catalyst_debug = '0'
            test_verbose = '--verbose=1' if @verbosity_type == 'high'
            catalyst_debug = '1' if @catalyst_debug == true
            cmd << "CATALYST_DEBUG=#{catalyst_debug} ./Build test #{test_verbose}"
            listener.info "ssh command: #{ssh_cmd} '#{cmd.join(' && ')}'"
            build.abort unless launcher.execute("bash", "-c", "#{ssh_cmd} '#{cmd.join(' && ')}'", { :out => listener } ) == 0

            # check paths
            @paths.split("\n").map {|l| l.chomp }.reject {|l| l.nil? || l.empty? || l =~ /^\s+#/ || l =~ /^#/ }.map{ |l| l.sub(/#.*/){""} }.each do |l|
                cmd = []
                cmd << "cd .perl_smoke_test/"
                cmd << "cd #{dist_dir}"
                if ( env['PERL5LIB'].nil? || env['PERL5LIB'].empty? )
                    cmd << "export PERL5LIB=./cpanlib/lib/perl5" 
                else
                    cmd << "export PERL5LIB=./cpanlib/lib/perl5:#{env['PERL5LIB']}" 
                end
                cmd << "perl -c #{l}"
                listener.info "ssh command: #{ssh_cmd} '#{cmd.join(' && ')}'"
                build.abort unless launcher.execute("bash", "-c", "#{ssh_cmd} '#{cmd.join(' && ')}'", { :out => listener } ) == 0
            end  


        end # if @enabled == true

    end

end
