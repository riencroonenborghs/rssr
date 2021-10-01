class RemoveShowSummaryFromFeeds < ActiveRecord::Migration[6.0]
  def change
    remove_column :feeds, :show_summary
  end
end
