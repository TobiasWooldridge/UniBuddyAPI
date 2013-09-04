class Api::V1::NewsController < Api::V1::BaseController
  def index
    @blog_posts = BlogPost.limit(5).order("published DESC").all
    respond_with(@blog_posts)
  end
end
