# Full-text index over rss_entries' title and summary, kept in sync by triggers so that
# bulk deletes (e.g. RssEntries::PurgeOldJob) and raw SQL writes are covered too.
class CreateRssEntriesFts < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      CREATE VIRTUAL TABLE rss_entries_fts USING fts5(
        title, summary,
        content='rss_entries', content_rowid='id',
        tokenize='porter unicode61 remove_diacritics 2'
      )
    SQL

    execute <<~SQL
      CREATE TRIGGER rss_entries_fts_after_insert AFTER INSERT ON rss_entries BEGIN
        INSERT INTO rss_entries_fts(rowid, title, summary) VALUES (new.id, new.title, new.summary);
      END
    SQL

    execute <<~SQL
      CREATE TRIGGER rss_entries_fts_after_delete AFTER DELETE ON rss_entries BEGIN
        INSERT INTO rss_entries_fts(rss_entries_fts, rowid, title, summary) VALUES ('delete', old.id, old.title, old.summary);
      END
    SQL

    execute <<~SQL
      CREATE TRIGGER rss_entries_fts_after_update AFTER UPDATE OF title, summary ON rss_entries BEGIN
        INSERT INTO rss_entries_fts(rss_entries_fts, rowid, title, summary) VALUES ('delete', old.id, old.title, old.summary);
        INSERT INTO rss_entries_fts(rowid, title, summary) VALUES (new.id, new.title, new.summary);
      END
    SQL

    execute "INSERT INTO rss_entries_fts(rss_entries_fts) VALUES ('rebuild')"
  end

  def down
    execute "DROP TRIGGER rss_entries_fts_after_update"
    execute "DROP TRIGGER rss_entries_fts_after_delete"
    execute "DROP TRIGGER rss_entries_fts_after_insert"
    execute "DROP TABLE rss_entries_fts"
  end
end
