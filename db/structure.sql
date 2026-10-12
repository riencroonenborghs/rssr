CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "rss_feeds" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "url" varchar NOT NULL, "active" boolean DEFAULT TRUE NOT NULL, "last_fetched_at" datetime(6), "error" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "title" varchar /*application='Rssreader'*/);
CREATE UNIQUE INDEX "index_rss_feeds_on_url" ON "rss_feeds" ("url") /*application='Rssreader'*/;
CREATE TABLE IF NOT EXISTS "rss_entries" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "rss_feed_id" integer NOT NULL, "guid" varchar NOT NULL, "title" varchar, "url" varchar, "summary" text, "published_at" datetime(6), "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "image_url" varchar /*application='Rssreader'*/, CONSTRAINT "fk_rails_7060743c31"
FOREIGN KEY ("rss_feed_id")
  REFERENCES "rss_feeds" ("id")
);
CREATE INDEX "index_rss_entries_on_rss_feed_id" ON "rss_entries" ("rss_feed_id") /*application='Rssreader'*/;
CREATE UNIQUE INDEX "index_rss_entries_on_rss_feed_id_and_guid" ON "rss_entries" ("rss_feed_id", "guid") /*application='Rssreader'*/;
CREATE TABLE IF NOT EXISTS "users" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "email" varchar DEFAULT '' NOT NULL, "encrypted_password" varchar DEFAULT '' NOT NULL, "reset_password_token" varchar, "reset_password_sent_at" datetime(6), "remember_created_at" datetime(6), "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE UNIQUE INDEX "index_users_on_email" ON "users" ("email") /*application='Rssreader'*/;
CREATE UNIQUE INDEX "index_users_on_reset_password_token" ON "users" ("reset_password_token") /*application='Rssreader'*/;
CREATE TABLE IF NOT EXISTS "subscriptions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "rss_feed_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_933bdff476"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_61b745bdbc"
FOREIGN KEY ("rss_feed_id")
  REFERENCES "rss_feeds" ("id")
);
CREATE INDEX "index_subscriptions_on_user_id" ON "subscriptions" ("user_id") /*application='Rssreader'*/;
CREATE INDEX "index_subscriptions_on_rss_feed_id" ON "subscriptions" ("rss_feed_id") /*application='Rssreader'*/;
CREATE UNIQUE INDEX "index_subscriptions_on_user_id_and_rss_feed_id" ON "subscriptions" ("user_id", "rss_feed_id") /*application='Rssreader'*/;
CREATE TABLE IF NOT EXISTS "bookmarks" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "rss_entry_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_c1ff6fa4ac"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_21e2430456"
FOREIGN KEY ("rss_entry_id")
  REFERENCES "rss_entries" ("id")
);
CREATE INDEX "index_bookmarks_on_user_id" ON "bookmarks" ("user_id") /*application='Rssreader'*/;
CREATE INDEX "index_bookmarks_on_rss_entry_id" ON "bookmarks" ("rss_entry_id") /*application='Rssreader'*/;
CREATE UNIQUE INDEX "index_bookmarks_on_user_id_and_rss_entry_id" ON "bookmarks" ("user_id", "rss_entry_id") /*application='Rssreader'*/;
CREATE TABLE IF NOT EXISTS "filters" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "kind" varchar NOT NULL, "value" varchar NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_f53aed9bb6"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_filters_on_user_id" ON "filters" ("user_id") /*application='Rssreader'*/;
CREATE UNIQUE INDEX "index_filters_on_user_id_and_kind_and_value" ON "filters" ("user_id", "kind", "value") /*application='Rssreader'*/;
CREATE VIRTUAL TABLE rss_entries_fts USING fts5(
  title, summary,
  content='rss_entries', content_rowid='id',
  tokenize='porter unicode61 remove_diacritics 2'
)
/* rss_entries_fts(title,summary) */;
CREATE TABLE IF NOT EXISTS 'rss_entries_fts_data'(id INTEGER PRIMARY KEY, block BLOB);
CREATE TABLE IF NOT EXISTS 'rss_entries_fts_idx'(segid, term, pgno, PRIMARY KEY(segid, term)) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS 'rss_entries_fts_docsize'(id INTEGER PRIMARY KEY, sz BLOB);
CREATE TABLE IF NOT EXISTS 'rss_entries_fts_config'(k PRIMARY KEY, v) WITHOUT ROWID;
CREATE TRIGGER rss_entries_fts_after_insert AFTER INSERT ON rss_entries BEGIN
  INSERT INTO rss_entries_fts(rowid, title, summary) VALUES (new.id, new.title, new.summary);
END;
CREATE TRIGGER rss_entries_fts_after_delete AFTER DELETE ON rss_entries BEGIN
  INSERT INTO rss_entries_fts(rss_entries_fts, rowid, title, summary) VALUES ('delete', old.id, old.title, old.summary);
END;
CREATE TRIGGER rss_entries_fts_after_update AFTER UPDATE OF title, summary ON rss_entries BEGIN
  INSERT INTO rss_entries_fts(rss_entries_fts, rowid, title, summary) VALUES ('delete', old.id, old.title, old.summary);
  INSERT INTO rss_entries_fts(rowid, title, summary) VALUES (new.id, new.title, new.summary);
END;
CREATE TABLE IF NOT EXISTS "rss_entry_reads" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "rss_entry_id" integer NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_05ca7a53d1"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_6298ee407e"
FOREIGN KEY ("rss_entry_id")
  REFERENCES "rss_entries" ("id")
 ON DELETE CASCADE);
CREATE INDEX "index_rss_entry_reads_on_user_id" ON "rss_entry_reads" ("user_id") /*application='Rssreader'*/;
CREATE INDEX "index_rss_entry_reads_on_rss_entry_id" ON "rss_entry_reads" ("rss_entry_id") /*application='Rssreader'*/;
CREATE UNIQUE INDEX "index_rss_entry_reads_on_user_id_and_rss_entry_id" ON "rss_entry_reads" ("user_id", "rss_entry_id") /*application='Rssreader'*/;
INSERT INTO "schema_migrations" (version) VALUES
('20261011010817'),
('20261009225331'),
('20261009225330'),
('20261009035747'),
('20261009035746'),
('20261009035247'),
('20261009033154'),
('20261009033153'),
('20261009032042'),
('20261009032041');

