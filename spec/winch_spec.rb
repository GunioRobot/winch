require File.dirname(__FILE__) + '/spec_helper.rb'

class Bat < ActiveResource::Base
  self.site = ''
end

class Cat < ActiveResource::Base
  self.site = ''

  must_have 'name', :default => 'Oreo'
  must_have 'legs', :default => [{'paws' => 'sharp', 'fur' => 'clean'},
	                               {'paws' => 'sharp', 'fur' => 'clean'},
	                               {'paws' => 'sharp', 'fur' => 'clean'},
	                               {'paws' => 'sharp', 'fur' => 'clean'}]
end

class Cat::Leg < ActiveResource::Base
  self.site = ''

  must_have 'paws', :faux => 'mysterious'
  must_have 'fur', :default => 'dirty'
end

class Goat < ActiveResource::Base
  self.site = ''

  must_have 'name', :default => 'billy'
  must_have 'legs', :default => [{'hoof' => 'clean'}, {}, {}, {}]
end

class Goat::Leg < ActiveResource::Base
  self.site = ''

  must_have 'hoof', :faux => 'mysterious'
  must_have 'fur', :default => 'dirty'
end

describe Winch do
  it "should work in the default situation" do
    Bat.new({}).should be_well_typed
  end
  
  it "should work with a basic winch case" do
    Cat::Leg.new({'paws' => 'sharp'}).tap do |cl|
      cl.paws.should eql('sharp')
      cl.fur.should eql('dirty')
      cl.should be_well_typed
    end
    
    Cat::Leg.new({'fur' => 'black'}).tap do |cl|
      cl.paws.should eql('mysterious')
      cl.fur.should eql('black')
      cl.should_not be_well_typed
      cl.broken_attributes.should eql(['paws'])
    end
  end
  
  it "should work with a nested winch case" do
    Goat.new({}).tap do |g|
      g.legs.each_with_index do |l, i|
        if [1, 2, 3].include?(i)
          l.hoof.should eql('mysterious')
          l.fur.should eql('dirty')
          l.should_not be_well_typed
        else
          l.hoof.should eql('clean')
          l.fur.should eql('dirty')
          l.should be_well_typed
        end
      end
      
      g.name.should eql('billy')
      g.should_not be_well_typed
      g.broken_attributes.should eql(['legs[1].hoof', 'legs[2].hoof', 'legs[3].hoof'])
    end
  end
end
