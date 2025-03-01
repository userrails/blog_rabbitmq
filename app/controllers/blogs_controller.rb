# app/controllers/blogs_controller.rb
class BlogsController < ApplicationController
  before_action :set_blog, only: [:show, :edit, :update, :destroy]
  
  def index
    @blogs = Blog.all
  end
  
  def show
  end
  
  def new
    @blog = Blog.new
  end
  
  def create
    @blog = Blog.new(blog_params)
    
    if @blog.save
      # Option 1: Direct publish to RabbitMQ
      RabbitMQ::Publishers::BlogPublisher.publish_created(@blog)
      
      # Option 2: Use Sidekiq to handle the message publishing
      # BlogWorker.perform_async(@blog.id, 'created')
      
      redirect_to @blog, notice: 'Blog was successfully created.'
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @blog.update(blog_params)
      # Direct publish
      RabbitMQ::Publishers::BlogPublisher.publish_updated(@blog)
      
      # Or via worker
      # BlogWorker.perform_async(@blog.id, 'updated')
      
      redirect_to @blog, notice: 'Blog was successfully updated.'
    else
      render :edit
    end
  end
  
  def destroy
    blog_id = @blog.id
    @blog.destroy
    
    # Direct publish
    RabbitMQ::Publishers::BlogPublisher.publish_deleted(blog_id)
    
    # Or via worker
    # BlogWorker.perform_async(blog_id, 'deleted')
    
    redirect_to blogs_url, notice: 'Blog was successfully destroyed.'
  end
  
  private
  
  def set_blog
    @blog = Blog.find(params[:id])
  end
  
  def blog_params
    params.require(:blog).permit(:title, :description)
  end
end