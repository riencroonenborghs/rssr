json.partial! "api/entries/entry", entry: @entry
json.url @entry.url
# Feed HTML is untrusted; only safe-listed tags and attributes are kept.
json.summary_html sanitize(@entry.summary)
