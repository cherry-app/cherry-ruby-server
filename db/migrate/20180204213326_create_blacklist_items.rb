class CreateBlacklistItems < ActiveRecord::Migration[5.1]
  def change
    create_table :blacklist_items do |t|
      t.string :word
      t.integer :score

      t.timestamps
    end
  end
end
