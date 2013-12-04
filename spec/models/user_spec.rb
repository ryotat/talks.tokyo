require 'spec_helper'

describe "User" do
  let(:user) { FactoryGirl.create(:user) }
  let(:user2) { FactoryGirl.create(:user) }
  let(:list) { FactoryGirl.create(:list, :organizer => user) }
  let(:list2) { FactoryGirl.create(:list, :organizer => user) }
  before do
    list2.users << user2
    list2.save!
  end
  context "Destroy" do
    before do
      @personal_list_id = user.personal_list.id
      @list_id = list.id
      @list2_id = list2.id
      user.destroy
    end
    specify do
      lambda { List.find(@personal_list_id) }.should raise_exception(ActiveRecord::RecordNotFound)
    end
    specify do
      lambda { List.find(@list_id) }.should raise_exception(ActiveRecord::RecordNotFound)
    end
    specify do
      lambda { List.find(@list2_id) }.should_not raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
