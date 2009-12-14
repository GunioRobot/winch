module Winch::Base
  module ClassMethods
    def must_have(name, options={})
      #Either :default, or :faux can be anything including false and '', just not nil
      raise "%s can have either a default or a faux value, but not both." % name unless options.values_at(:default, :faux).one? { |v| !v.nil? }

      self.must_haves = (self.must_haves || []).push(options.merge(:name => name))
    end
  end
  
  module InstanceMethods
    def initialize_winch(attributes)
      (self.must_haves || []).each do |clause| 
        name = clause[:name]

        next unless attributes[name].nil?

        if clause[:default].nil?
          @broken_attributes = (@broken_attributes || []).push(name)
          attributes[name] = clause[:faux]
        else
          attributes[name] = clause[:default]
        end
      end
    end
      
    def preform_type_check
      @broken_attributes = (@broken_attributes || []) + attributes.keys.collect do |name|
        if attributes[name].kind_of?(ActiveResource::Base) && !attributes[name].well_typed?
          attributes[name].broken_attributes.collect { |a| "%s.%s" % [name, a] }
        elsif attributes[name].kind_of?(Array)
          attributes[name].to_enum(:each_with_index).collect do |node, index|
            node.broken_attributes.collect { |a| "%s[%s].%s" % [name, index, a] } unless node.well_typed?
          end
        else
          nil
        end
      end.flatten.compact

      @well_typed = @broken_attributes.blank?
    end
  end
  
  def self.included(klass)
    klass.class_eval do
      class_inheritable_array :must_haves, :instance_writer => false
      attr_reader :well_typed, :broken_attributes
      alias_method :well_typed?, :well_typed
      
      extend ClassMethods
      include InstanceMethods
    end
  end
end