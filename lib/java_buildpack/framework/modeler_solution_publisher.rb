# Encoding: utf-8
# Cloud Foundry Java Buildpack
# Copyright 2013 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'fileutils'
require 'java_buildpack/component/versioned_dependency_component'
require 'java_buildpack/framework'

module JavaBuildpack::Framework

  # Encapsulates the functionality for enabling zero-touch AppDynamics support.
  class ModelerSolutionPublisher < JavaBuildpack::Component::VersionedDependencyComponent

    def initialize(context)
      super(context)
	  ENV['CSP_HOME'] = "csp_home"
    end  
  
    # Modifies the application's file system.  The component is expected to transform the application's file system in
    # whatever way is necessary (e.g. downloading files or creating symbolic links) to support the function of the
    # component.  Status output written to +STDOUT+ is expected as part of this invocation
	#
    # @return [void]
    def compile
      download_zip false
    end

    # Modifies the application's runtime configuration. The component is expected to transform members of the +context+
    # (e.g. +@java_home+, +@java_opts+, etc.) in whatever way is necessary to support the function of the component.
    #
    # Container components are also expected to create the command required to run the application.  These components
    # are expected to read the +context+ values and take them into account when creating the command.
    #
    # @return [void, String] components other than containers are not expected to return any value.  Container
    #                        components are expected to return the command required to run the application.
    def release
	  java_opts   = @droplet.java_opts
	  java_opts.add_system_property('java.library.path', "$PWD/#{(@droplet.sandbox).relative_path_from(@droplet.root)}")
    end

    protected

    # Whether or not this component supports this application
    #
    # @return [Boolean] whether or not this component supports this application
    def supports?
	  set_env_default "LD_LIBRARY_PATH" "#{@droplet.sandbox.to_str}"
	  true
    end

	def add_to_profiled(string)
	  FileUtils.mkdir_p "#{@droplet.root.to_str}/.profile.d"
      File.open("#{@droplet.root.to_str}/.profile.d/msp.sh", "a") do |file|
        file.puts string
      end
    end

    def set_env_default(key, val)
      add_to_profiled "export #{key}=${#{key}:-#{val}}"
    end
  
  end

end
