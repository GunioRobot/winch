require 'rubygems'
require 'active_resource'

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module Winch
  VERSION = '0.0.1'
  
  autoload :Base, 'winch/base'
end

require 'active_resource_boot/base'