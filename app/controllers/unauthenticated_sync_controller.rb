class UnauthenticatedSyncController < ApiController

    def professions
        professions = Profession.select(:id, :name)
        render json: professions, status: 200
    end
    
end
