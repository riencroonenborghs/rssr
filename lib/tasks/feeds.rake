require "opml-parser"

namespace :feeds do
  include OpmlParser

  desc "Import"
  task import: :environment do
    data = HTTParty.get("https://raw.githubusercontent.com/m8/refined.blog/master/data.json").body
    data = JSON.parse(data)["data"]
    data.each do |item|
      pp "Importing #{item['furl']}"
      next unless item["furl"]

      if (feed = Feed.find_by(url: item["furl"]))
        pp "-- exists, adding tags #{item['tags']}"
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
    rescue StandardError => e
      pp "something happened"
      pp e.message
    end
  end

  desc "Import various"
  task import_various: :environment do
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
      tag = URI.decode url.split("/").last.gsub(".opml", "") # rubocop:disable Lint/UriEscapeUnescape
      data = HTTParty.get(url).body
      list = OpmlParser.import data
      list.select { |item| item.attributes[:type] == "rss" }.each do |item|
        attributes = item.attributes
        pp "Importing #{attributes[:xmlUrl]}"
        if (feed = Feed.find_by(url: attributes[:xmlUrl]))
          feed.tag_list.add(tag)
          feed.description = attributes[:description]
          feed.save!
        else
          Feed.create! url: attributes[:xmlUrl], name: attributes[:title], tag_list: tag
        end
      rescue StandardError => e
        pp "something happened"
        pp e.message
      end
    end
  end

  desc "Import tech"
  task import_tech: :environment do
    [
      "https://gist.githubusercontent.com/webpro/5907452/raw/a71a3b59c108267fb667510dbe91154035f1ed10/feeds.opml",
      "https://pastebin.com/raw/teAMsvZK"
    ].each do |url|
      tag = "tech"
      data = HTTParty.get(url).body
      list = OpmlParser.import data
      list.select { |item| item.attributes[:type] == "rss" }.each do |item|
        attributes = item.attributes
        pp "Importing #{attributes[:xmlUrl]}"
        if (feed = Feed.find_by(url: attributes[:xmlUrl]))
          feed.tag_list.add(tag)
          feed.description = attributes[:description]
          feed.save!
        else
          Feed.create! url: attributes[:xmlUrl], name: attributes[:title], tag_list: tag
        end
      rescue StandardError => e
        pp "something happened"
        pp e.message
      end
    end
  end

  desc "Import news"
  task import_news: :environment do
    [
      "https://raw.githubusercontent.com/scripting/feedsForJournalists/master/list.opml",
      "https://raw.githubusercontent.com/newman8r/us-newspapers-opml/master/us-newspapers.opml"
    ].each do |url|
      tag = "news"
      data = HTTParty.get(url).body
      list = OpmlParser.import data
      list.select { |item| item.attributes[:type] == "rss" }.each do |item|
        attributes = item.attributes
        pp "Importing #{attributes[:xmlUrl]}"
        if (feed = Feed.find_by(url: attributes[:xmlUrl]))
          feed.tag_list.add(tag)
          feed.description = attributes[:description]
          feed.save!
        else
          Feed.create! url: attributes[:xmlUrl], name: attributes[:title], tag_list: tag
        end
      rescue StandardError => e
        pp "something happened"
        pp e.message
      end
    end
  end

  desc "Import yaml"
  task import_yaml: :environment do
    url = "https://raw.githubusercontent.com/tzano/wren/master/wren/config/rss_feeds.yml"
    data = HTTParty.get(url).body
    yaml = YAML.safe_load data
    yaml.each_key do |tag1|
      list = yaml[tag1]
      list.each_key do |tag2|
        list2 = list[tag2]
        list2.each_key do |tag3|
          url = list2[tag3]
          pp "Importing #{url}"
          if (feed = Feed.find_by(url: url))
            feed.tag_list.add(tag1)
            feed.tag_list.add(tag2)
            feed.tag_list.add(tag3)
            feed.save!
          else
            Feed.create! url: url, name: "#{tag2} - #{tag3}", tag_list: "#{tag1},#{tag2},#{tag3}"
          end
        end
      end
    end
  end

  desc "Import datorss"
  task import_datorss: :environment do
    (1..28).each do |page|
      url = "https://www.datorss.com/feeds.csv?page=#{page}"
      data = HTTParty.get(url).body
      csv = CSV.parse data
      csv.each_with_index do |line, index|
        next if index.zero? # header

        url, title, description, = line
        url = url.slice(5, url.size) if url.starts_with?("feed:")
        url = url.slice(5, url.size) if url.starts_with?("feed:")
        url = "http:#{url}" if url.starts_with?("//")
        title = title.force_encoding('utf-8').encode
        pp "Importing #{page}/#{index} #{url}"
        if (feed = Feed.find_by(url: url))
          feed.tag_list.add("various")
          feed.save!
        else
          Feed.create! url: url, name: title, tag_list: "various", description: description
        end
      rescue StandardError => e
        pp "something happened"
        pp e.message
      end
    end
  end

  desc "Import blog.feedspot.com URLs"
  task import_blog_feedspot_url: :environment do
    url = ARGV[1]
    tag_list = ARGV[2]

    service = LoadUrl.call(url: url)
    response = Nokogiri::HTML service.data
    as = response.css(".trow a")

    rss = []
    as.to_a.in_groups_of(3).each do |block|
      rss << block[0].attributes["href"].value
    end

    rss.each do |rss_url|
      pp "----- url: #{rss_url}"
      next if Feed.exists?(url: rss_url)

      pp "----- url: #{rss_url} -- adding"
      Feed.create! url: url, tag_list: tag_list
      sleep 1
    rescue StandardError => e
      pp "----- url: #{rss_url} -- ERROR"
      pp e.message
    end
  end
end
