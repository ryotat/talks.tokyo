require 'spec_helper'

describe "User" do
  let(:user) { FactoryGirl.create(:user) }
  before do
  end
  context "Destroy" do
    before do
      @personal_list_id = user.personal_list.id
      p "personal_list=#{@personal_list_id}"
      user.destroy
    end
    specify do
      lambda { List.find(@personal_list_id) }.should raise_exception(ActiveRecord::RecordNotFound)
    end
  end
end
