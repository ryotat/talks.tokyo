# -*- coding: utf-8 -*-
require 'spec_helper'

describe "Documents" do
  subject { page }
  let(:user) { FactoryGirl.create(:user) }
  let(:text) { "Blablablablablablabla" }
  context "new" do
    before do
      sign_in user
      visit document_path("NewPage")
      fill_in 'document_body', :with => text
      click_button 'Save'
    end
    it { should have_content "New Page" }
    it { should have_content text }
    context "edit" do
      before do
        click_link "Edit"
        fill_in 'document_body', :with => "Another text."
        click_button 'Save'
      end
      it { should have_content "Your changes have been saved." }
      it { should have_content "Another text." }
    end
  end

end
