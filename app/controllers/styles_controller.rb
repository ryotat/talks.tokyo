class StylesController < ApplicationController
  # GET /styles/lists.css
  def lists
    @lists = List.where("style is not null")
    render :formats => [:text], :content_type => "text/css", :layout => false
  end
end
