require 'spec_helper'

describe ListTalk do
  context "talk.ex_directory and !list.ex_directory" do
    let(:talk) { FactoryGirl.create(:talk, :ex_directory => true) }
    let(:list) { FactoryGirl.create(:list, :ex_directory => false) }
    specify { ListTalk.new(:talk => talk, :list => list).should_not be_valid }
  end
end
