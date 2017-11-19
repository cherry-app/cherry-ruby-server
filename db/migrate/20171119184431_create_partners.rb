class CreatePartners < ActiveRecord::Migration[5.1]
  def change
    create_table :partners do |t|
      t.string :name
      t.string :key
      t.boolean :active

      t.timestamps
    end
  end
end
