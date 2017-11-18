class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # rescue_from StandardError,
  # with: :render_standard_error

#   def render_standard_error
#     render json: {
#     status: 500,
#     error: 'Unhandled error',
#     message: 'An unexpected error occurred.'
#   }, status: :internal_server_error
# end
end
