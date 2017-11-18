class SignupController < ApplicationController
    skip_before_action :verify_authenticity_token
    def do
        name = params["name"]
        phone_number = params["phone_number"]

        user = User.new(:name => name, :uid => phone_number, :verified => false, )
        user.save()

        render :plain => "Hello, " + name
    end
end
