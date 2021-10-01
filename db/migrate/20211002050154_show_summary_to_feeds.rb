class ShowSummaryToFeeds < ActiveRecord::Migration[6.0]
  def change
    add_column :feeds, :show_summary, :boolean, default: true
  end
end
