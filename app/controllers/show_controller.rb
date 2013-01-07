Mime::Type.register "text/plain", :txt
Mime::Type.register "text/plain", :email

class ShowController < ApplicationController
  
  # We do this to avoid creating numerous sessions for rss
  # feed requests, xml requests, e-mail requests etc.
  # session :off, :if => Proc.new { |request| request.parameters[:layout] }
  
  layout :decode_layout
  before_filter :decode_div_embed
  before_filter :decode_time_period
  before_filter :decode_list_details

  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :action => 'xml', :formats => [:xml], :layout => false }
      format.rss  { render :action => 'rss', :formats => [:xml], :layout => false }
      format.txt  { render :action => 'text', :formats => [:html], :layout => false }
      format.email { render :action => 'email', :formats => [:html], :layout => false }
      format.ics { render :text => @talks.to_ics }
    end
  end
  
  private
	
  def decode_layout
    params[:layout] || 'application'
  end

  def decode_div_embed
    @div_embed = params[:divid] || 'talks'
  end
  
  def decode_time_period
    @list = List.find params[:id]
    finder = TalkFinder.new(params)
    @errors = finder.errors
    @talks = @list.talks.find( :all, finder.to_find_parameters)
  end
  
  # FIXME: Refactor so that can set this from url
  def decode_list_details
    @list_details = true
    true # Must return true for method to continue
  end	
end
