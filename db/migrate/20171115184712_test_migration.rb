class TestMigration < ActiveRecord::Migration[5.1]
  def change
    create_table :test do |t|
      t.string :name
    end
  end
end
