class TicklesController < ApplicationController
  before_filter :ensure_user_is_logged_in

  def create
    params[:tickle].merge!( :sender => User.current ) if User.current
    params[:tickle].merge!( :sender_ip => request.remote_ip )
    @tickle = Tickle.new(params[:tickle])
    if @tickle.save
      flash[:confirm] = "e-mail sent to #{@tickle.recipient_email}."
      respond_to do |format|
        format.html do
          case @tickle.about
          when Talk; redirect_to talk_url(:id => @tickle.about_id)
          when List; redirect_to list_url(:id => @tickle.about_id)
          end
        end
        format.json { render :json => { 'confirm' => "e-mail sent to #{@tickle.recipient_email}." } }
        end
    else
      respond_to do |format|
        format.html { render :action => "new" }
        format.json { render :json => { 'error' =>  "could not send e-mail to #{@tickle.recipient_email}." } }
      end
    end
  end

  def tell_a_friend
    params[:tickle].merge!( :sender => User.current ) if User.current
    @tickle = Tickle.new(params[:tickle])
    @tickle.set_default_subject_body
    respond_to do |format|
      format.html { render :partial => 'tell_a_friend' }
    end
  end
end
