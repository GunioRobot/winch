module Winch::Base
  module ClassMethods
    def must_have(name, options={})
      #Either :default, or :faux can be anything including false and '', just not nil
      raise "%s can have either a default or a faux value, but not both." % name unless options.values_at(:default, :faux).select { |v| !v.nil? }.length == 1

      self.must_haves = (self.must_haves || {}).merge(name => options.merge(:name => name))
    end
  end
  
  module InstanceMethods
    def initialize_winch(attributes)
      (self.must_haves || {}).each do |name, clause|
        set_default_for_attribute(attributes, clause)
      end
    end

    def preform_type_check
      @broken_attributes ||= []
      attributes.keys.each { |name| find_broken_in_node(name, attributes[name]) }
      @well_typed = @broken_attributes.blank?

      return if @well_typed
      return unless self.class.parent == Object
      
      raise Winch::TypeError.new(:object => self) if Winch.config.raise_on_broken_attributes
    end

    private

    def set_default_for_attribute(attributes, clause)
      name = clause[:name]

      return unless attributes[name].nil?

      if clause[:default].nil?
        @broken_attributes = (@broken_attributes || []).push(name)
        attributes[name] = clause[:faux]
      else
        attributes[name] = clause[:default]
      end
    end

    def find_broken_in_active_resource(name, node)
      @broken_attributes += node.broken_attributes.collect { |a| "%s.%s" % [name, a] } unless node.well_typed?
    end

    def find_broken_in_collection(name, node)
      node.each_with_index do |child_node, index|
        find_broken_in_node("%s[%s]" % [name, index], child_node)
      end
    end

    def find_broken_in_node(name, node)
      if node.kind_of?(ActiveResource::Base)
        find_broken_in_active_resource(name, node)
      elsif node.kind_of?(Array)
        find_broken_in_collection(name, node)
      end
    end
  end

  def self.included(klass)
    klass.class_eval do
      class_inheritable_hash :must_haves, :instance_writer => false

      attr_reader :well_typed, :broken_attributes
      alias_method :well_typed?, :well_typed
      
      extend ClassMethods
      include InstanceMethods
    end
  end
end

module Winch
  def self.config
    @@config ||= OpenStruct.new(:raise_on_broken_attributes => false)
  end
end

class Winch::TypeError < Exception
  attr_accessor :object

  def initialize(options={})
    self.object = options[:object]
  end
end