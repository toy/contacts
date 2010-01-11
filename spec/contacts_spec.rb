require File.dirname(__FILE__) + '/spec_helper'

class User < ActiveRecord::Base
  include Contacts
end

describe Contacts do
  it "should store icq number" do
    User.create(:icq => '12345')
    p = User.first
    p.icq.should == '12345'
  end
end
