class ApiController < ApplicationController

    before_action :require_partner_id_check

    def require_partner_id_check
        partner_id = request.headers["Cherry-Partner-ID"]

        partner = Partner.where(:key => partner_id).first

        if partner == nil
            render json: {
                message: 'Invalid partner ID'
              }, status: 403
        end
    end

end