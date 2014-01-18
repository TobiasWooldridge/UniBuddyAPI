class Api::V2::NewsController < Api::V2::BaseController
  def index
    @blog_posts = BlogPost.for_institution(params[:inst_code]).limit(5).order("published DESC").all
    
    respond_with padded_response @blog_posts
  end
end
