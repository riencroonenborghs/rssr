user = User.create!(email: ENV['EMAIL'], password: ENV['PASSWORD'], password_confirmation: ENV['PASSWORD'])

# rubocop:disable Layout/ArrayAlignment
[["https://www.standaard.be/rss/section/1f2838d4-99ea-49f0-9102-138784c7ea7c", "news, national, België"],
  ["https://www.standaard.be/rss/section/e70ccf13-a2f0-42b0-8bd3-e32d424a0aa0", "news, world, België"],
  ["https://www.hbvl.be/rss/section/0DB351D4-B23C-47E4-AEEB-09CF7DD521F9", "news, national, Limburg, België"],
  ["http://rubyland.news/feed.rss	", "tech, development, ruby, ruby on rails"],
  ["http://feeds.bbci.co.uk/news/world/rss.xml", "news, world"],
  ["http://rss.slashdot.org/Slashdot/slashdot", "tech"],
  ["https://feeds.simplecast.com/54nAGcIl", "news, world, misc"],
  ["https://www.boredpanda.com/funny/feed/", "images, funny, humour"],
  ["https://www.theonion.com/content/feeds/daily", "news, satire, humour, funny"],
  ["https://railsware.com/blog/feed/", "tech, development, ruby, ruby on rails"],
  ["https://ruby.libhunt.com/newsletter/feed", "tech, development, ruby, ruby on rails"],
  ["https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss", "images, science, space"],
  ["http://feeds.wired.com/wired/index", "tech"],
  ["http://www.newyorker.com/feed/humor", "humour, funny"],
  ["http://news.ycombinator.com/rss", "tech"],
  ["https://www.stuff.co.nz/rss", "news, national, world, NZ"],
  ["http://xkcd.com/atom.xml", "humour, funny, images"],
  ["http://feeds.feedburner.com/Explosm", "humour, funny, images"],
  ["http://feeds.mashable.com/Mashable", "tech, misc"],
  ["http://feeds.arstechnica.com/arstechnica/index/", "tech, misc"],
  ["http://www.lifehack.org/feed", "tech, misc"],
  ["http://feeds.macrumors.com/MacRumors-All", "tech, mac"],
  ["http://feeds.feedburner.com/oatmealfeed", "images, humour, funny"],
  ["http://krebsonsecurity.com/feed/", "tech, security"],
  ["https://martinfowler.com/feed.atom", "tech, development"],
  ["https://feeds.feedburner.com/TechCrunch/", "tech, misc"],
  ["http://feeds.arstechnica.com/arstechnica/technology-lab", "misc"]].each do |item|
  url, tag_list = item
  feed = Feed.create!(url: url, tag_list: tag_list)
  user.subscriptions.create!(feed: feed)
rescue StandardError => e
  pp e.message
end
# rubocop:enable Layout/ArrayAlignment
