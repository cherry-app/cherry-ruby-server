class UniquenessFix < ActiveRecord::Migration[5.1]
  def change
    remove_index :users, :uid
    add_index :users, [:uid, :verified], unique: true
  end
end
