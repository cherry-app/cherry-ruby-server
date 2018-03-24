class CreateProfessions < ActiveRecord::Migration[5.1]
  def change
    create_table :professions do |t|
      t.string :name
      
      t.timestamps
    end
    add_index :professions, :id
  end
end
