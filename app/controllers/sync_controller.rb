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
        items = BlacklistItem.select(:id, :word, :score)
        render json: items, status: 200
    end

end
