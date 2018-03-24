class Profession < ApplicationRecord
    has_and_belongs_to_many :blacklist_items
end
