user = User.create!(email: <YOUR EMAIL>, password: <PASSWORD>, password_confirmation: <PASSWORD>)

["https://www.standaard.be/rss/section/1f2838d4-99ea-49f0-9102-138784c7ea7c",
  "https://www.standaard.be/rss/section/e70ccf13-a2f0-42b0-8bd3-e32d424a0aa0",
  "https://www.hbvl.be/rss/section/0DB351D4-B23C-47E4-AEEB-09CF7DD521F9",
  "https://thespinoff.co.nz/feed/",
  "http://rubyland.news/feed.rss	",
  "http://feeds.bbci.co.uk/news/world/rss.xml",
  "http://rss.slashdot.org/Slashdot/slashdot",
  "https://feeds.simplecast.com/54nAGcIl",
  "https://blog.imgur.com/feed/",
  "https://www.boredpanda.com/funny/feed/",
  "https://www.theonion.com/content/feeds/daily",
  "https://railsware.com/blog/feed/",
  "https://ruby.libhunt.com/newsletter/feed",
  "https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss",
  "http://feeds.wired.com/wired/index",
  "http://www.newyorker.com/feed/humor",
  "Http://www.fark.com/fark.rss",
  "http://news.ycombinator.com/rss",
  "https://www.stuff.co.nz/rss",
  "http://www.interest.co.nz/rss"].each do |url|
    user.feeds.create!(url: url)
  rescue => e
  end