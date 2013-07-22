require 'spec_helper'

shared_examples "proper talk" do
  it "should belong to its series" do
    talk.series.talks.should include(talk)
  end
end

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
  context "Public talk" do
    let(:talk) { FactoryGirl.create(:talk, :ex_directory => false) }
    it_behaves_like "proper talk"
  end
  context "Private talk" do
    let(:talk) { FactoryGirl.create(:talk, :ex_directory => true) }
    it_behaves_like "proper talk"
  end

end
