namespace :rss do
  desc "Download from RSS feeds on the Flinders website"

  task :blogs => :environment do
    desc "Pull blogs"

    feed = Feedzirra::Feed.fetch_and_parse("http://blogs.flinders.edu.au/flinders-news/feed/")

    feed.entries.each do |entry|
      remote_id = entry.entry_id.scan(/\d+/).first.to_i

      post = BlogPost.where(:remote_id => remote_id).first

      if post.nil?
        post = BlogPost.new
        post.remote_id = remote_id
      end

      post.url = entry.url
      post.title = entry.title
      post.content = entry.content
      post.published = entry.published
      post.last_modified = entry.last_modified

      post.save

      p "Saving post %s" % post.remote_id
    end
  end
end
