#!/usr/bin/env ruby

require 'optparse'
require 'json'
require 'fileutils'
require_relative 'gem_generator'
require_relative 'operator_generator'
require_relative 'github_actions_generator'
require_relative 'charts_generator'


options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: scaffold.rb [options]"

  opts.on("-n", "--name NAME", "The name of the scaffold (required)") do |name|
    options[:name] = name
  end
  
  opts.on("-p", "--plural NAMES", "The name (plural) from crd (required)") do |plural|
    options[:crd_plural] = plural
  end
  
  opts.on("-v", "--version VERSION", "The ApiVersion from crd (required)") do |version|
    options[:crd_version] = version
  end

  opts.on("-g", "--apigroup APIGROUP", "The api group of the scaffold (required)") do |group|
    options[:crd_group] = group
  end


  opts.on("-s", "--sleeptimer SLEEPTIMER", "The thoughput of requests to K8s cluster (optional)") do |sleep_timer|
    options[:sleepTimer] = sleep_timer
  end

  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

# Check if required arguments are given
unless options[:name] && options[:crd_group] && options[:crd_version] && options[:crd_plural]
  puts "Error: Name, Apigroup, version and name plural are required."
  exit 1
end


options[:name] = options[:name].capitalize

operator_options = {}
if options[:namespace]
  operator_options[:namespace] = options[:namespace]
end
if options[:sleepTimer]
  operator_options[:sleepTimer] = options[:sleepTimer].to_i
end
operator_options = operator_options.to_json.gsub('"namespace":', " namespace: ").gsub('"sleepTimer":', " sleepTimer: ").gsub('}', " }")




OperatorGenrator.new(options, operator_options).genrate

GemGenerator.new.generate

ChartsGenerator.new(options).generate

GithubActionsGenerator.new.generate








  
  