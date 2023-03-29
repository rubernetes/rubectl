class OperatorGenrator
  def initialize(options, operator_options)
    @options = options
    @docker_file = <<~HEREDOC
                  FROM ruby:3.0
                  WORKDIR /usr/src/app
                  COPY Gemfile Gemfile.lock ./
                  RUN bundle install
                  COPY . .
                  RUN chmod 777 ./#{options[:name].downcase}_controller.rb
                  HEREDOC
    
    @ruby_file = <<~HEREDOC
                # frozen_string_literal: true

                require 'rubernetes'

                # Create a new operator that handlle the events callbacks
                # @param crd_group [string] ApiGroup from crd
                # @param crd_version [string] ApiVersion from crd
                # @param crd_plural [string] Name (plural) from crd
                # @param options [Hash] Additional options
                class #{options[:name]}Controller < Rubernetes::Operator
                  def initialize(crd_group, crd_version, crd_plural, options = {})
                    super(crd_group, crd_version, crd_plural, options)
                  end

                  # Event callback when a #{options[:name].downcase} is added, you can add your cutom logic
                  # here that will be triggered when a #{options[:name].downcase} is added
                  # @param event [Hash] Event from the watcher that contains all information about
                  # the #{options[:name].downcase} that you will need
                  def added(event)
                    @logger.info 'new #{options[:name].downcase} has been added on the cluster'
                    # custom logic to handle the creation of a #{options[:name].downcase}

                    # example of how to set and get the status of a #{options[:name].downcase}
                    set_status(event, { foo: 'foo', bar: 'bar' })
                    # @status = get_status(event)
                  end

                  # Event callback when a #{options[:name].downcase} is modified, you can add
                  # your cutom logic here that will be triggered when a #{options[:name].downcase} is modified
                  # @param event [Hash] Event from the watcher that contains all information about
                  # the #{options[:name].downcase} that you will need
                  def modified(event)
                    @logger.info 'a #{options[:name].downcase} has been modified on the cluster'
                    # custom logic to handle the modification of a #{options[:name].downcase}

                    @logger.info event
                  end

                  # Event callback when a #{options[:name].downcase} is deleted, you can add
                  # your cutom logic here that will be triggered when a #{options[:name].downcase} is deleted
                  # @param event [Hash] Event from the watcher that contains all information about
                  # the #{options[:name].downcase} that you will need
                  def deleted(_event)
                    @logger.info 'a #{options[:name].downcase} has been deleted from the cluster'
                    # custom logic to handle the deletion of a #{options[:name].downcase}
                  end
                end
                #{options[:name]}Controller.new('#{options[:crd_group].downcase}', '#{options[:crd_version].downcase}', '#{options[:crd_plural].downcase}', #{operator_options}).run
                HEREDOC

  end
  def genrate
    File.write("#{@options[:name].downcase}_controller.rb", @ruby_file)
    File.write("Dockerfile", @docker_file)
  end
end