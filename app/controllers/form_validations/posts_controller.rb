class FormValidations::PostsController < PostsController
  def update
    @post.assign_attributes(post_params)
    @post.valid?
    respond_to do |format|
      format.json { render partial: 'posts/form', locals: { post: @post }, formats: [:html] } 
    end
  end
  
  def create
    @post = Post.new(post_params)
    @post.validate
    respond_to do |format|
      format.json { render partial: 'posts/form', locals: { post: @post }, formats: [:html] } 
    end
  end
end
