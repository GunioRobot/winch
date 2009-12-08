require File.dirname(__FILE__) + '/spec_helper.rb'

class Bat < ActiveResource::Base
end

class Cat < ActiveResource::Base
  self.site = ''
  must_have 'fur'
end

describe Winch do
  it "should work in the default situation" do
    Bat.new({}).should be_well_typed
  end
  
  it "should work with a basic winch case" do
    Cat.new({:fur => 'black'}).should be_well_typed
    Cat.new({:eyes => 'black'}).should_not be_well_typed
  end
end
