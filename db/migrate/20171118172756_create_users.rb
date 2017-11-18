class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :uid
      t.string :password_hash
      t.string :salt
      t.integer :type
      t.boolean :verified
      t.string :auth
      t.string :login_code

      t.timestamps
    end

    add_index :uid, unique: true
  end
end
