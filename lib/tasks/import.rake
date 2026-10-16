namespace :import do
  desc "Import users, feeds, entries, subscriptions and bookmarks from a previous version's database " \
       "into the current environment (default: storage/production.sqlite3). Existing records are kept."
  task :legacy, [ :path ] => :environment do |_task, args|
    path = args[:path].presence || Rails.root.join("storage/production.sqlite3").to_s
    puts "Importing #{path} into the #{Rails.env} database…"

    Imports::LegacyDatabaseService.call(path).each do |name, (imported, total)|
      puts format("  %<name>-14s %<imported>6d imported, %<present>6d already present (%<total>d in source)",
                  name: "#{name}:", imported: imported, present: total - imported, total: total)
    end
  end
end
