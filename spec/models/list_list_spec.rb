require 'spec_helper'

describe ListTalk do
  context "talk.ex_directory and !list.ex_directory" do
    let(:private_list) { FactoryGirl.create(:list, :ex_directory => true) }
    let(:list) { FactoryGirl.create(:list, :ex_directory => false) }
    specify { ListList.new(:child => private_list, :list => list).should_not be_valid }
  end
end
