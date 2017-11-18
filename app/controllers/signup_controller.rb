require 'bcrypt'

class SignupController < ApplicationController
    skip_before_action :verify_authenticity_token
    def do
        name = params["name"]
        phone_number = params["phone_number"]

        unverifiedUser = User.where(:uid => phone_number, :verified => false).first
        if unverifiedUser != nil
            unverifiedUser.delete()
        end
        otp = 6.times.map { rand(0..9) }.join
        salt = BCrypt::Engine.generate_salt
        send_otp(otp, phone_number)
        login_token = Digest::MD5.hexdigest(BCrypt::Engine.hash_secret(otp, salt))

        newUser = User.new(:name => name, :uid => phone_number, :verified => false, :login_code => otp, :auth => login_token, :salt => salt)
        newUser.save()

        render :json => {
            message: 'OTP sent',
            token: login_token
        }, status: 200
        
    end

    def send_otp(otp, phone_number)
        require 'net/http'
        
        uri = URI.parse("http://api.msg91.com/api/v2/sendsms")
        
        http = Net::HTTP.new(uri.host, uri.port)
        req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
        req['authkey'] = ENV['MSG91_AUTH_KEY']
        req.body = {
            sender: 'CHERRY',
            route: '4',
            country: '91',
            sms: [
                message: 'Your OTP for logging in to Cherry is ' + otp + '.',
                to: [
                    phone_number
                ]
            ]
        }.to_json
        res = http.request(req)
        
        # Shortcut
        #response = Net::HTTP.post_form(uri, {"user[name]" => "testusername", "user[email]" => "testemail@yahoo.com"})
        
        
        
    end

    def verify
        otp = params["otp"]
        login_token = params["login_token"]

        user = User.where(:login_code => otp, :auth => login_token).first
    
        if user != nil

            existingUser = User.where(:uid => user.uid, :verified => true).first
            if existingUser != nil
                existingUser.uid = nil
                existingUser.save()
            end

            auth_token = Digest::MD5.hexdigest(BCrypt::Engine.hash_secret(login_token, user.salt))
            user.verified = true
            user.auth = auth_token
            user.save()
            
            render :json => {
                message: "Login successful",
                token: auth_token
            }, status: 200
        else
            render :json => {
                message: "Incorrect OTP or token"
            }, status: 401
        end
    end
end
