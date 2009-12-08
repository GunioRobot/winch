module Winch::Base
  module ClassMethods
    def must_have(name, options={})
      self.must_haves = (self.must_haves || []).push(options.merge(:name => name))
    end
  end
  
  module InstanceMethods
    def well_typed?
      @well_typed ||= lambda do
        (self.must_haves || []).all? { |i| attributes[i[:name]] }
      end.call
    end
  end
  
  def self.included(klass)
    klass.class_eval do
      class_inheritable_accessor :must_haves, :instance_writer => false

      extend ClassMethods
      include InstanceMethods
    end
  end
end