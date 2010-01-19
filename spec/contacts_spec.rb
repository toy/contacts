require File.dirname(__FILE__) + '/spec_helper'

class Post < ActiveRecord::Base
end

class User < ActiveRecord::Base
  has_contacts :icq, :skype, :test
end

class User2 < User
  has_contacts :all
end

class User3 < User
  has_contacts :all, :except => :facebook
end

class User4 < User
  has_contacts :all, :except => [:facebook, :flickr]
end

describe Contacts do
  it "should not auto insert accessors" do
    Post.new.should_not respond_to(:icq, :icq=, :icq?, :icq_link)
  end

  it "should auto insert all accessors which were asked for" do
    User.new.should respond_to(:icq, :icq=, :icq?, :icq_link)
    User.new.should_not respond_to(:facebook, :facebook=, :facebook?, :facebook_link)
  end

  it "should auto insert all accessors if asked for all" do
    Contacts.contact_types.keys.each do |contact|
      User2.new.should respond_to(:"#{contact}", :"#{contact}=", :"#{contact}?", :"#{contact}_link")
    end
  end

  it "should skip accessor for contacts listed in :except option" do
    User.new.should_not respond_to(:facebook, :facebook=, :facebook?, :facebook_link)
    User.new.should_not respond_to(:flickr, :flickr=, :flickr?, :flickr_link)
    User2.new.should respond_to(:facebook, :facebook=, :facebook?, :facebook_link)
    User2.new.should respond_to(:flickr, :flickr=, :flickr?, :flickr_link)
    User3.new.should_not respond_to(:facebook, :facebook=, :facebook?, :facebook_link)
    User3.new.should respond_to(:flickr, :flickr=, :flickr?, :flickr_link)
    User4.new.should_not respond_to(:facebook, :facebook=, :facebook?, :facebook_link)
    User4.new.should_not respond_to(:flickr, :flickr=, :flickr?, :flickr_link)
  end

  it "should store test string" do
    Contacts.contact :test
    User.create!(:test => '12345')
    User.last.test.should == '12345'
  end

  it "should store unformatted contact" do
    User.class_eval do
      has_contact :city, :as => :unformatted
    end
    User.create!(:city => '12345')
    User.last.city.should == '12345'
  end


  describe "with wrong value" do
    before do
      Contacts.contact :test do
        sanitizer %r{^\d+$}
      end
    end

    it "should not save if trying to create with wrong value" do
      User.create(:test => 'abc').should be_new_record
    end

    it "should raise error if trying to create! with wrong value" do
      proc{
        User.create!(:test => 'abc')
      }.should raise_error(ActiveRecord::RecordInvalid)
    end

    it "should leave value that was set" do
      User.new(:test => 'abc').test.should == 'abc'
    end
  end

  describe "sanitizing" do
    it "should sanitize using regexp" do
      Contacts.contact :test do
        sanitizer %r{[b-e]+}
      end
      User.new(:test => 'abcdef').test.should == 'bcde'
      User.new(:test => 'ghijkl').test.should == 'ghijkl'
    end

    it "should sanitize using regexp with selector" do
      Contacts.contact :test do
        sanitizer %r{^ab(.*)}
      end
      User.new(:test => 'abcdef').test.should == 'cdef'
      User.new(:test => 'ghijkl').test.should == 'ghijkl'
    end

    it "should sanitize using block/proc" do
      Contacts.contact :test do
        sanitizer do |value|
          value.gsub(%r{[b-e]+}, '-')
        end
      end
      User.new(:test => 'abcdef').test.should == 'a-f'
      User.new(:test => 'ghijkl').test.should == 'ghijkl'
    end

    it "should sanitize using array of regexps" do
      Contacts.contact :test do
        sanitizer [%r{\d+}, %r{[A-Z]+}, %r{[b-e]+}]
      end
      User.new(:test => 'abcdef').test.should == 'bcde'
      User.new(:test => 'ghijkl').test.should == 'ghijkl'
    end

    it "should sanitize using array of regexps with selector" do
      Contacts.contact :test do
        sanitizer [%r{^\d(.*)}, %r{^[A-Z](.*)}, %r{^[a-f](.*)}]
      end
      User.new(:test => 'abcdef').test.should == 'bcdef'
      User.new(:test => 'ghijkl').test.should == 'ghijkl'
    end

    it "should not sanitize if sanitizer is nil" do
      Contacts.contact :test
      User.new(:test => 'abcdef').test.should == 'abcdef'
    end

    it "should raise for unknown sanitizer" do
      Contacts.contact :test do
        sanitizer 123
      end
      proc{
        User.new(:test => 'abcdef')
      }.should raise_error('Unknown type of sanitizer: 123')
    end
  end

  describe "formatting" do
    it "should format using string" do
      Contacts.contact :test do
        formatter 'hello %s'
      end
      User.new(:test => 'abcdef').test_link.should == 'hello abcdef'
    end

    it "should format using block/proc" do
      Contacts.contact :test do
        formatter do |value|
          value.gsub(/./, '\0\0')
        end
      end
      User.new(:test => 'abcdef').test_link.should == 'aabbccddeeff'
    end

    it "should leave value as is when formatter is nil" do
      Contacts.contact :test
      User.new(:test => 'abcdef').test_link.should == 'abcdef'
    end

    it "should raise for unknown formatter" do
      Contacts.contact :test do
        formatter 123
      end
      proc{
        User.new(:test => 'abcdef').test_link
      }.should raise_error('Unknown type of formatter: 123')
    end
  end

  describe "cloning contacs" do
    it "should get rules for contact with :as => :test from test contact" do
      User.class_eval do
        has_contacts :test_a, :test_b, :as => :test
        has_contact :test_c, :as => :test
        has_contact :test_z
      end
      Contacts.contact :test do
        sanitizer %r{[b-e]+}
        formatter 'hello %s'
      end
      Contacts.contact :test_a
      Contacts.contact :test_b
      Contacts.contact :test_c
      Contacts.contact :test_z

      user = User.new do |u|
        u.test = 'abcdef'
        u.test_a = 'abcdef'
        u.test_b = 'abcdef'
        u.test_c = 'abcdef'
        u.test_z = 'abcdef'
      end

      user.test.should == 'bcde'
      user.test_a.should == 'bcde'
      user.test_b.should == 'bcde'
      user.test_c.should == 'bcde'
      user.test_z.should == 'abcdef'
      user.test_link.should == 'hello bcde'
      user.test_a_link.should == 'hello bcde'
      user.test_b_link.should == 'hello bcde'
      user.test_c_link.should == 'hello bcde'
      user.test_z_link.should == 'abcdef'
    end
  end

  describe "sorting and duplicates" do
    it "should complain about sort order if it is turned on" do
      RAILS_DEFAULT_LOGGER.should_receive(:warn).with('contact type b is out of order')
      contact_types = Contacts.contact_types.dup
      begin
        Contacts.contact_types.replace({})
        Contacts.sorted do
          Contacts.contact :a
          Contacts.contact :c
          Contacts.contact :b
        end
      ensure
        Contacts.contact_types.replace(contact_types)
      end
    end

    it "should not complain about sort order if it is not turned on" do
      RAILS_DEFAULT_LOGGER.should_not_receive(:warn)
      contact_types = Contacts.contact_types.dup
      begin
        Contacts.contact_types.replace({})
        Contacts.contact :a
        Contacts.contact :c
        Contacts.contact :b
      ensure
        Contacts.contact_types.replace(contact_types)
      end
    end

    it "should complain about duplicates" do
      RAILS_DEFAULT_LOGGER.should_receive(:warn).with('contact type a already defined')
      contact_types = Contacts.contact_types.dup
      begin
        Contacts.contact_types.replace({})
        Contacts.contact :a
        Contacts.contact :b
        Contacts.contact :a
      ensure
        Contacts.contact_types.replace(contact_types)
      end
    end
  end
end
