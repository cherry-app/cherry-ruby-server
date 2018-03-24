class CreateJoinTableBlacklistItemsProfessions < ActiveRecord::Migration[5.1]
  def change
    create_join_table :blacklist_items, :professions do |t|
      t.index([:blacklist_item_id, :profession_id], name: 'by_blacklist_item_id')
      t.index([:profession_id, :blacklist_item_id], name: 'by_profession_item_id')
    end
  end
end
