class UpcaseAllTags < ActiveRecord::Migration[6.1]
  def up
    Tag.find_each do |t|
      t.update(name: t.name.upcase)
    end
  end

  def down
  end
end
