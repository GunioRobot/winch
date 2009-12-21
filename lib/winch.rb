require 'rubygems'
require 'active_resource'

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Winch
  VERSION = '0.0.4' unless defined?(Winch::VERSION)
end

require 'winch/base'
require 'active_resource_boot/base'