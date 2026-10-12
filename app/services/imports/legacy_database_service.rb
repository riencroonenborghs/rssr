module Imports
  # Copies users, feeds, entries, subscriptions and bookmarks from a database of the previous
  # version of this app (feeds/entries tables) into the current database. The source is opened
  # read-only. Records that already exist are kept as they are (users by email, feeds by URL,
  # entries by feed and GUID, subscriptions and bookmarks by user and feed/entry), so the import
  # can be run again. Everything is written in one transaction.
  #
  # Returns { users: [imported, in_source], feeds: [...], entries: [...], subscriptions: [...],
  # bookmarks: [...] }.
  class LegacyDatabaseService < ApplicationService
    BATCH_SIZE = 1_000

    def initialize(path)
      @path = File.expand_path(path)
    end

    def call
      raise ArgumentError, "No database at #{path}" unless File.file?(path)
      raise ArgumentError, "#{path} is the current database" if path == current_database_path

      # Opened directly rather than through Active Record, which would configure it for writing.
      # immutable: read without taking locks or creating WAL files next to the source.
      @source = SQLite3::Database.new(
        "file:#{ERB::Util.url_encode(path).gsub('%2F', '/')}?immutable=1",
        flags: SQLite3::Constants::Open::READONLY | SQLite3::Constants::Open::URI,
        results_as_hash: true
      )

      ActiveRecord::Base.transaction do
        user_ids = import_users
        feed_ids = import_feeds
        {
          users: @users_count,
          feeds: @feeds_count,
          entries: import_entries(feed_ids),
          subscriptions: import_subscriptions(user_ids, feed_ids),
          bookmarks: import_bookmarks(user_ids, feed_ids)
        }
      end
    ensure
      @source&.close
    end

    private
      attr_reader :path

      def current_database_path
        File.expand_path(ActiveRecord::Base.connection_db_config.database, Rails.root)
      end

      def source_rows(sql)
        @source.execute(sql)
      end

      # Source user id => current user id.
      def import_users
        rows = source_rows("SELECT id, email, encrypted_password, remember_created_at, created_at, updated_at FROM users")
        # Passwords are copied as their bcrypt hashes, so they keep working.
        @users_count = [ insert(User, rows.map { |row| row.except("id") }, unique_by: :email), rows.size ]

        ids_by_email = User.where(email: rows.pluck("email")).pluck(:email, :id).to_h
        rows.to_h { |row| [ row["id"], ids_by_email.fetch(row["email"]) ] }
      end

      # Source feed id => current feed id.
      def import_feeds
        rows = source_rows("SELECT id, url, title, active, error, created_at, updated_at FROM feeds")
        @feeds_count = [ insert(RssFeed, rows.map { |row| row.except("id") }, unique_by: :url), rows.size ]

        ids_by_url = RssFeed.where(url: rows.pluck("url")).pluck(:url, :id).to_h
        rows.to_h { |row| [ row["id"], ids_by_url.fetch(row["url"]) ] }
      end

      def import_entries(feed_ids)
        imported = total = 0
        last_id = 0
        loop do
          rows = source_rows(<<~SQL)
            SELECT id, feed_id, uuid, link, title, description, published_at, image, created_at, updated_at
            FROM entries WHERE id > #{Integer(last_id)} ORDER BY id LIMIT #{BATCH_SIZE}
          SQL
          break if rows.empty?

          last_id = rows.last["id"]
          total += rows.size
          imported += insert(RssEntry, rows.map { |row| entry_attributes(row, feed_ids) }, unique_by: %i[rss_feed_id guid])
        end
        [ imported, total ]
      end

      def entry_attributes(row, feed_ids)
        {
          rss_feed_id: feed_ids.fetch(row["feed_id"]),
          guid: row["uuid"],
          url: row["link"],
          title: row["title"],
          summary: row["description"],
          published_at: row["published_at"],
          image_url: row["image"].to_s.match?(%r{\Ahttps?://}) ? row["image"] : nil,
          created_at: row["created_at"],
          updated_at: row["updated_at"]
        }
      end

      def import_subscriptions(user_ids, feed_ids)
        rows = source_rows("SELECT user_id, feed_id, created_at, updated_at FROM subscriptions WHERE active = 1")
        attributes = rows.map do |row|
          { user_id: user_ids.fetch(row["user_id"]), rss_feed_id: feed_ids.fetch(row["feed_id"]),
            created_at: row["created_at"], updated_at: row["updated_at"] }
        end
        [ insert(Subscription, attributes, unique_by: %i[user_id rss_feed_id]), rows.size ]
      end

      # Bookmarked entries are found by their feed and GUID, as entry ids differ between databases.
      def import_bookmarks(user_ids, feed_ids)
        rows = source_rows(<<~SQL)
          SELECT bookmarks.user_id, bookmarks.created_at, bookmarks.updated_at, entries.feed_id, entries.uuid
          FROM bookmarks JOIN entries ON entries.id = bookmarks.entry_id
        SQL
        attributes = rows.filter_map do |row|
          entry_id = RssEntry.where(rss_feed_id: feed_ids.fetch(row["feed_id"]), guid: row["uuid"]).pick(:id)
          next unless entry_id

          { user_id: user_ids.fetch(row["user_id"]), rss_entry_id: entry_id,
            created_at: row["created_at"], updated_at: row["updated_at"] }
        end
        [ insert(Bookmark, attributes, unique_by: %i[user_id rss_entry_id]), rows.size ]
      end

      # Inserts the rows, skipping ones that already exist; returns how many were inserted.
      def insert(model, rows, unique_by:)
        return 0 if rows.empty?

        model.insert_all(rows, unique_by: unique_by, returning: [ :id ]).length
      end
  end
end
