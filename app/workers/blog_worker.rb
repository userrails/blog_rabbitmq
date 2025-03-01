# app/workers/blog_worker.rb
class BlogWorker
  include Sidekiq::Worker
  
  def perform(blog_id, action)
    blog = Blog.find_by(id: blog_id)
    return unless blog
    
    case action
    when 'created'
      RabbitMQ::Publishers::BlogPublisher.publish_created(blog)
    when 'updated'
      RabbitMQ::Publishers::BlogPublisher.publish_updated(blog)
    when 'deleted'
      RabbitMQ::Publishers::BlogPublisher.publish_deleted(blog_id)
    end
  end
end
