# -*- coding: utf-8 -*-
class Talks::SpecialMessagesController < ApplicationController
  before_filter :ensure_user_is_logged_in

  def edit
    return page404 unless find_talk
    return page403 unless user_can_edit_talk?       
    render :layout => false
  end

  def update
    return page404 unless find_talk
    return page403 unless user_can_edit_talk?       
    @talk.special_message = params[:talk][:special_message]
    if @talk.save
      @response = {:confirm => "Successfully updated the special message."}
    else
      @response = {:error => "Could not save it."}
    end
  end


  private
  
  def find_talk
    return nil unless params[:id]
    begin
      @talk = Talk.find params[:id]
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end

  include CommonTalkMethods
end
