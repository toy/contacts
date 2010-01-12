require File.dirname(__FILE__) + '/spec_helper'

class User < ActiveRecord::Base
  include Contacts
end

describe Contacts do
  it "should store test string" do
    Contacts.contact :test
    User.create(:test => '12345')
    user = User.first
    user.test.should == '12345'
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
      User.create(:test => 'abc').test.should == 'abc'
    end
  end

  describe "sanitizing" do
    it "should sanitize using regexp" do
      Contacts.contact :test do
        sanitizer %r{[b-e]+}
      end
      User.create(:test => 'abcdef').test.should == 'bcde'
      User.create(:test => 'ghijkl').test.should == 'ghijkl'
    end

    it "should sanitize using regexp with selector" do
      Contacts.contact :test do
        sanitizer %r{^ab(.*)}
      end
      User.create(:test => 'abcdef').test.should == 'cdef'
      User.create(:test => 'ghijkl').test.should == 'ghijkl'
    end

    it "should sanitize using block/proc" do
      Contacts.contact :test do
        sanitizer do |value|
          value.gsub(%r{[b-e]+}, '-')
        end
      end
      User.create(:test => 'abcdef').test.should == 'a-f'
      User.create(:test => 'ghijkl').test.should == 'ghijkl'
    end

    it "should sanitize using array of regexps" do
      Contacts.contact :test do
        sanitizer [%r{\d+}, %r{[A-Z]+}, %r{[b-e]+}]
      end
      User.create(:test => 'abcdef').test.should == 'bcde'
      User.create(:test => 'ghijkl').test.should == 'ghijkl'
    end

    it "should sanitize using array of regexps with selector" do
      Contacts.contact :test do
        sanitizer [%r{^\d(.*)}, %r{^[A-Z](.*)}, %r{^[a-f](.*)}]
      end
      User.create(:test => 'abcdef').test.should == 'bcdef'
      User.create(:test => 'ghijkl').test.should == 'ghijkl'
    end

    it "should not sanitize if sanitizer is nil" do
      Contacts.contact :test
      User.create(:test => 'abcdef').test.should == 'abcdef'
    end

    it "should raise for unknown sanitizer" do
      Contacts.contact :test do
        sanitizer 123
      end
      proc{
        User.create(:test => 'abcdef')
      }.should raise_error('Unknown type of sanitizer: 123')
    end
  end

  describe "formatting" do
    it "should format using string" do
      Contacts.contact :test do
        formatter 'hello %s'
      end
      User.create(:test => 'abcdef').test_link.should == 'hello abcdef'
    end

    it "should format using block/proc" do
      Contacts.contact :test do
        formatter do |value|
          value.gsub(/./, '\0\0')
        end
      end
      User.create(:test => 'abcdef').test_link.should == 'aabbccddeeff'
    end

    it "should leave value as is when formatter is nil" do
      Contacts.contact :test
      User.create(:test => 'abcdef').test_link.should == 'abcdef'
    end

    it "should raise for unknown formatter" do
      Contacts.contact :test do
        formatter 123
      end
      proc{
        User.create(:test => 'abcdef').test_link
      }.should raise_error('Unknown type of formatter: 123')
    end
  end
end
