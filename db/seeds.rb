user = User.create!(email: ENV.fetch('EMAIL'), password: ENV.fetch('PASSWORD'), password_confirmation: ENV.fetch('PASSWORD'))

[["https://www.standaard.be/rss/section/1f2838d4-99ea-49f0-9102-138784c7ea7c", "News, Europe"],
  ["https://www.standaard.be/rss/section/e70ccf13-a2f0-42b0-8bd3-e32d424a0aa0", "News, World"],
  ["https://www.hbvl.be/rss/section/0DB351D4-B23C-47E4-AEEB-09CF7DD521F9", "News, Local"],
  ["http://rubyland.news/feed.rss", "Tech, Programming, Ruby on Rails"],
  ["http://feeds.bbci.co.uk/news/world/rss.xml", "News, World"],
  ["http://rss.slashdot.org/Slashdot/slashdot", "Tech"],
  ["https://feeds.simplecast.com/54nAGcIl", "News, World"],
  ["https://www.boredpanda.com/funny/feed/", "Humour"],
  ["https://www.theonion.com/content/feeds/daily", "Humour"],
  ["https://railsware.com/blog/feed/", "Tech, Programming, Ruby on Rails"],
  ["https://ruby.libhunt.com/newsletter/feed", "Tech, Programming, Ruby on Rails"],
  ["https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss", "Science"],
  ["http://feeds.wired.com/wired/index", "Tech"],
  ["http://www.newyorker.com/feed/humor", "Humour"],
  ["http://news.ycombinator.com/rss", "Tech"],
  ["https://www.stuff.co.nz/rss", "News, NZ"],
  ["http://xkcd.com/atom.xml", "Humour"],
  ["http://feeds.feedburner.com/Explosm", "Humour"],
  ["http://feeds.mashable.com/Mashable", "Tech"],
  ["http://feeds.arstechnica.com/arstechnica/index/", "Tech"],
  ["http://www.lifehack.org/feed", "Tech"],
  ["http://feeds.macrumors.com/MacRumors-All", "Tech"],
  ["http://feeds.feedburner.com/oatmealfeed", "Humour"],
  ["http://krebsonsecurity.com/feed/", "Tech"],
  ["https://martinfowler.com/feed.atom", "Tech, Programming"],
  ["https://feeds.feedburner.com/TechCrunch/", "Tech"],
  ["http://feeds.arstechnica.com/arstechnica/technology-lab", "Tech"]].each do |item|
    url, tag_names = item

    puts "Creating subscription for #{url}"
    service = Subscriptions::CreateSubscription.perform(
      user: user,
      url: url,
      name: nil,
      get_name_from_url: true,
      tag_names: tag_names
    )
    if service.failure?
      puts service.errors.full_messages.to_sentence
      next
    end 
  end

Feed.find_each do |feed|
  puts "Refreshing feed #{feed.name}"
  Feeds::RefreshFeed.perform(feed: feed)
end

JSON.parse(File.read("filters.json")).each do |(c,v)|
  user.filters.create!(comparison: c, value: v)
end
