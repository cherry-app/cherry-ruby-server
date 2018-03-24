class SyncController < AuthenticatedApiController

    def contacts
        numbers = []
        params["numbers"].each do |number|
            numbers << number
        end
        uids = User.where(uid: numbers).pluck(:uid)
        render json: uids, status: 200
    end

    def blacklist
        profession_id = params["profession_id"]
        items = BlacklistItem
            .joins(:professions)
            .select(:id, :word, :score, 'blacklist_items_professions.profession_id')
            .where('blacklist_items_professions.profession_id' => profession_id)
        render json: items, status: 200
    end

    def professions
        professions = Profession.select(:id, :name)
        render json: professions, status: 200
    end

end
