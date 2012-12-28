require 'spec_helper'
describe Talk do
  it "should not create a user when speaker_email is empty" do
    talk = FactoryGirl.create(:talk, :speaker_email => "")
    User.find_by_name(talk.name_of_speaker).should == nil
  end
  it "should not ensure user exists when speaker is nil" do
    talk = FactoryGirl.create(:talk, :speaker_email => "")
    talk = Talk.find_by_id(talk.id)
    talk.ex_directory = 1
    talk.save!
  end
end
