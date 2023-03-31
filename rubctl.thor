require 'json'
ENV['THOR_SILENCE_DEPRECATION'] = ''
class Rubctl < Thor::Group
  include Thor::Actions

  # Define arguments and options
  argument :name, :banner => "\n\targ[1] - The name of the scaffold (required)\n"
  argument :crd_plural, :banner => "\targ[2] - The name (plural) from crd (required)\n"
  argument :crd_version, :banner => "\targ[3] - The ApiVersion from crd (required)\n"
  argument :crd_api_group, :banner => "\targ[4] - The api group of the scaffold (required)\n"
  argument :crd_short, :banner => "\targ[5] - The short name of the crd (required)\n"
  argument :container_registry_url, :banner => "\targ[6] - The container registry url that will have the docker image (required)\n"
  argument :container_registry, :banner => "\targ[7] - The container registry name that will have the docker image (required)\n"
  argument :repository_name, :banner => "\targ[8] - The repository name (required)\n"
  class_option :sleeptimer, { :banner => 'The throughput of requests to K8s cluster (optional)', :type => :numeric }
  class_option :namespace, { :banner => 'The namespace of the scaffold (optional)', :type => :string }

  def self.source_root
    File.dirname(__FILE__)
  end

  def create_params
    if options[:namespace].nil?
      @type = 'clustered'
    else
      @type = 'namespaced'
    end


    @operator_options = {}
    @operator_options[:namespace] = @options[:namespace] if @options[:namespace]
    @operator_options[:sleepTimer] = @options[:sleeptimer].to_i if @options[:sleeptimer]
    @operator_options = @operator_options.to_json.gsub('"namespace":', ' namespace: ').gsub('"sleepTimer":', ' sleepTimer: ').gsub(
      '}', ' }'
    )
  end

  def create_docker_file
    template('templates/Dockerfile.tt', "#{name.downcase}/Dockerfile")
  end

  def create_gem_files
    template('templates/Gemfile.tt', "#{name.downcase}/Gemfile")
    template('templates/Gemfile.lock.tt', "#{name.downcase}/Gemfile.lock")
  end

  def create_git_files
    template('templates/build.yaml.tt', "#{name.downcase}/.github/workflows/build.yaml")
  end
  
  def create_operator_file
    template('templates/controller.rb.tt', "#{name.downcase}/#{name.downcase}_controller.rb")
  end

  def create_charts_file
    template('templates/values.yaml.tt', "#{name.downcase}/helm-#{@type}/values.yaml")
    template('templates/Chart.yaml.tt', "#{name.downcase}/helm-#{@type}/Chart.yaml")
    template('templates/.helmignore.tt', "#{name.downcase}/helm-#{@type}/.helmignore")
    template('templates/crd.yaml.tt', "#{name.downcase}/helm-#{@type}/templates/crd.yaml")
    template('templates/_helpers.tpl.tt', "#{name.downcase}/helm-#{@type}/templates/_helpers.tpl")
    template('templates/deployment.yaml.tt', "#{name.downcase}/helm-#{@type}/templates/deployment.yaml")
    template('templates/hpa.yaml.tt', "#{name.downcase}/helm-#{@type}/templates/hpa.yaml")
    template('templates/service.yaml.tt', "#{name.downcase}/helm-#{@type}/templates/service.yaml")
    template('templates/service_account.yaml.tt', "#{name.downcase}/helm-#{@type}/templates/service_account.yaml")
    template("templates/rbac_#{@type}.yaml.tt", "#{name.downcase}/helm-#{@type}/templates/rbac.yaml")

  end


  def put_note
    say '=' * 100
    say "Scaffold for #{options[:name]} created.", :green
    say 'Note: inorder to use the github action, you need to add REPO_ACCESS_TOKEN to your repo secrets.', :blue
    say '=' * 100
  end
end