class RemoveWatches < ActiveRecord::Migration[7.2]
  def change
    drop_table :watches
  end
end
