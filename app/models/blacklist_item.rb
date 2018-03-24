class BlacklistItem < ApplicationRecord
    has_and_belongs_to_many :professions
end
