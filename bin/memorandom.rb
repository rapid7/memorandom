#!/usr/bin/env ruby

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "..", "lib")))
require 'optparse'
require 'ostruct'
require 'memorandom'

options = {}

option_parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options] file1 file2 ... fileN"
  opts.separator "Extracts interesting data from binary files"
  opts.separator ""
  opts.separator "Options"

  opts.on("-p", "--plugins [plugin1,plugin2,plugin3...]", 
          "Specify a list of plugin names to use, otherwise use all plugins" 
    ) do |plugins|
    options[:plugins] = plugins.split(",").map{ |x| x.downcase.strip }
  end

  opts.on("-o", "--output [directory]",
          "Specify the directory in which to store found data") do |out|
    options[:output] = out
  end

  opts.on("-w", "--window [number]",
          "Specify the number of kilobytes to scan at once (default: 1024).") do |num|
    options[:window] = (num.to_i == 0) ? (1024*1024) : (num.to_i * 1024)
  end

  opts.on("-x", "--overlap [number]",
          "Specify the number of kilobytes to overlap between windows (default: 4).") do |num|
    options[:overlap] = (num.to_i == 0) ? (4*1024) : (num.to_i * 1024)
  end

  opts.on("-l", "--list-plugins",
          "List all of the available plugins") do
    puts ""
    puts "Memorandom Plugins"
    puts "==============="

    Memorandom::PluginManager.plugins.each_pair do |name, klass|
      puts "   * #{name.ljust(24)} #{klass.description}"
    end
    puts ""
    exit
  end

  opts.on("-h", "--help", "Show this message.") do
    puts opts
    exit
  end
end
option_parser.parse!(ARGV)

if ARGV.count < 1
  puts option_parser
  exit
end

scanner = Memorandom::Scanner.new(options)
if scanner.plugins.length == 0
  $stderr.puts "Error: No valid plugins have been selected"
  exit(1)
end

ARGV.each do |target|
  scanner.scan(target)
end