require "opml-parser"
include OpmlParser

namespace :feeds do
  desc "Import first batch of curated feeds"
  task import: :environment do
    data = HTTParty.get("https://raw.githubusercontent.com/m8/refined.blog/master/data.json").body
    data = JSON.parse(data)["data"]
    data.each do |item|
      pp "Importing #{item["furl"]}"
      next unless item["furl"]
      if (feed = Feed.find_by(url: item["furl"]))
        pp "-- exists, adding tags #{item["tags"]}"
        item["tags"].each do |tag|
          feed.tag_list.add(tag)
        end
        pp "-- saving"
        feed.save!
        pp "-- saved"
      else
        pp "-- new!"
        Feed.create! url: item["furl"], name: item["name"], tag_list: item["tags"].join(", ")
      end
    rescue => e
      pp "something happened"
      pp e.message
    end
  end

  desc "Import 2nd batch of curated feeds"
  task import2: :environment do
    [
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/Australia.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/Bangladesh.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/Brazil.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/Canada.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/France.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/Germany.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/Hong%20Kong%20SAR%20China.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/India.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/Indonesia.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/Iran.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/Ireland.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/Italy.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/Japan.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/Mexico.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/Myanmar%20(Burma).opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/Nigeria.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/Pakistan.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/Philippines.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/Poland.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/Russia.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/South%20Africa.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/Spain.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/Ukraine.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/United%20Kingdom.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/countries/without_category/United%20States.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Android%20Development.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Android.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Apple.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Architecture.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Android.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Beauty.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Books.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Business%20%26%20Economy.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Cars.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Cricket.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/DIY.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Fashion.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Food.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Football.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Funny.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Gaming.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/History.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Interior%20design.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Movies.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Music.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/News.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Personal%20finance.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Photography.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Programming.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Science.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Space.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Sports.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Startups.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Tech.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Television.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Tennis.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Travel.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/UI%20-%20UX.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/Web%20Development.opml",
      "https://raw.githubusercontent.com/plenaryapp/awesome-rss-feeds/master/recommended/without_category/iOS%20Development.opml"
    ].each do |url|
      tag = URI.decode url.split("/").last.gsub(".opml","")
      data = HTTParty.get(url).body
      list = OpmlParser.import data
      list.select do |item|
        item.attributes[:type] == "rss"
      end.each do |item|
        attributes = item.attributes
        pp "Importing #{attributes[:xmlUrl]}"
        if (feed = Feed.find_by(url: attributes[:xmlUrl]))
          feed.tag_list.add(tag)
          feed.description = attributes[:description]
          feed.save!
        else
          Feed.create! url: attributes[:xmlUrl], name: attributes[:title], tag_list: tag
        end
      rescue => e
        pp "something happened"
        pp e.message
      end
    end
  end
end
