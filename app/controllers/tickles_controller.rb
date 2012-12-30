class TicklesController < ApplicationController
  before_filter :ensure_user_is_logged_in

  def create
    params[:tickle].merge!( :sender => User.current ) if User.current
    params[:tickle].merge!( :sender_ip => request.remote_ip )
    @tickle = Tickle.new(params[:tickle])
    if @tickle.save
      flash[:confirm] = "e-mail sent to #{@tickle.recipient_email}."
      case @tickle.about
      when Talk; redirect_to talk_url(:id => @tickle.about_id)
      when List; redirect_to list_url(:id => @tickle.about_id)
      end
    else
      render :action => "new"
    end
  end

  def tell_a_friend
    params[:tickle].merge!( :sender => User.current ) if User.current
    @tickle = Tickle.new(params[:tickle])
    @tickle.set_default_subject_body
    respond_to do |format|
      format.js
    end
  end
end
