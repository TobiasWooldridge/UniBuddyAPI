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
      post.published = entry.published
      post.last_modified = entry.last_modified

      doc = Nokogiri::HTML.fragment(entry.content)
      doc.css("abbr.unapi-id").remove

      doc.css('p').find_all.each do |p|
          if p.content.blank?
            p.remove 
          end
      end


      # Extract content image/caption

      mode = "default"

      if not doc.css("p.MsoNormal").nil?
        # Oh no, this post has been polluted by copy-pasted MS Office HTML :[
        mode = "microsoft"
      end


      if mode == "default"
        post.image = doc.css("div.wp-caption > a").first.attribute("href").text
        post.caption = doc.css("div.wp-caption p.wp-caption-text").first.text

        doc.css("div.wp-caption").first.remove

      elsif mode == "microsoft"
        # office-HTML polluted posts have no captions
        post.image = doc.css("a").first.attribute("href").text
        post.caption = ""

        doc.css("a").first.remove
      end

      post.plaintext = doc.text.strip
      post.content = Sanitize.clean(doc.to_html.strip, Sanitize::Config::RELAXED)

      post.save

      p "Saving post %s as %s" % [post.remote_id, post.id]
    end
  end
end
