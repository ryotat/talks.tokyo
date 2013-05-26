class ImagesController < ApplicationController
  
  caches_page :show
  
  def show
    magick = Image.find(params[:id]).to_magick(params[:geometry])
    headers['Cache-Control'] = 'public'
    if magick
      send_data(magick.to_blob, :type => magick.mime_type, :disposition => 'inline')
    else
       render :text => "No data in image", :status => 404
    end
  end

  def delete
    return page404 unless find_image
    return page403 unless user_can_edit_image?
    render :layout => false
  end

  def destroy
    return page404 unless find_image
    return page403 unless user_can_edit_image?
    @image.destroy
    respond_to do |format|
      format.html { redirect_to @parent }
      format.json { head :no_content }
    end
  end

  private
  
  def find_image
    return nil unless params[:id]
    @image = Image.find(params[:id])
    @parent = @image.user || @image.talk || @image.list
  end
  
  def user_can_edit_image?
    return false unless @parent
    @parent.editable?
  end

end
