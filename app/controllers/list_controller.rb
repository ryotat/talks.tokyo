class ListController < ApplicationController
  
  before_filter :ensure_user_is_logged_in, :except =>  %w{ index }
  before_filter :find_list, :except => %w{ new create choose }
  before_filter :check_can_edit_list, :except => %w{ index new create choose }
  
  def new
    @list = List.new
    @list.ex_directory = false
  end
  
  def create
    @list = List.new params[:list]
    if @list.save
      @list.users << User.current
      flash[:confirm] = "Successfully created  &#145;#{@list.name}&#146;"
      if params[:return_to]
        redirect_to params[:return_to]
      else
        redirect_to list_url(:id => @list.id)
      end
    else
      render :action => 'new'
    end
  end
  
  # Other views include edit and edit_details
  
  def update
    if @list.update_attributes( params[:list] )
      flash[:confirm] = 'Details updated.'
    end
    redirect_to :action => 'edit', :id => @list
  end
  
  # Delete this list
  def destroy
    @list.sort_of_delete
    @list.save
    flash[:confirm] = "List &#145;#{@list.name}&#146; has been deleted."
    if User.current.personal_list
      redirect_to list_url(:id => User.current.personal_list.id )
    else
      redirect_to home_url
    end
  end

  def show_talk_post_url
    @url = new_posted_talk_url(:list_id => @list.id, :key => @list.talk_post_password)
    @generate_path = list_details_path(:action => 'generate_talk_post_url', :id => @list.id,  :format => 'js')
    respond_to do |format|
      format.js
    end
  end

  def generate_talk_post_url
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    random_password = Array.new(20).map { chars[rand(chars.size-1)] }.join
    @list.talk_post_password = random_password
    @list.save!
    @url = new_posted_talk_url(:list_id => @list.id, :key => random_password)
    render :action => 'show_talk_post_url', :format => 'js'
  end
  
  # Still left over. Need to refactor this elsewhere
  
  def choose
    @lists = User.current.lists
  end
    
  private
  
  # Filters
  
  def find_list
    @list = List.find params[:id]
  end
  
  def check_can_edit_list
    return true if @list.editable?
    render :text => "Permission denied", :status => 401
    false
  end
  
end
