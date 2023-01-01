class PopulateRssUrls < ActiveRecord::Migration[6.0]
  def change
    Feed.all.each do |feed|
      feed.update(rss_url: feed.url)
    end
  end
end
