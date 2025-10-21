pg_dump --data-only --inserts -t 'users|feeds|filters|subscriptions|taggings|tags|schema_migrations' rssreader-dev > dump.sql

https://stackoverflow.com/questions/6148421/how-to-convert-a-postgres-database-to-sqlite

- Remove the lines starting with SET
- Remove the lines starting with SELECT pg_catalog.setval
- Replace true for ‘t’
- Replace false for ‘f’
- Add BEGIN; as first line and END; as last line
- Replace "public." with empty string: sed 's/public\.//g'  dump.sql > dump2.sql

Recreate an empty development database. rails db:drop db:create db:migrate
Import the dump.

sqlite3 storage/development.sqlite3
sqlite> delete from schema_migrations;
sqlite> .read dump2.sql