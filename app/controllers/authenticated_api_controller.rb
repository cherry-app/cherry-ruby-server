class AuthenticatedApiController < ApiController

    before_action :require_auth_check

    def require_auth_check
        uid = request.headers["Cherry-UID"]
        auth = request.headers["Cherry-Auth-Token"]

        user = User.where(:auth => auth, :uid => uid, :verified => true).first

        if user == nil
            render json: {
                message: 'User not authenticated or verified'
              }, status: 401
        end
    end

end