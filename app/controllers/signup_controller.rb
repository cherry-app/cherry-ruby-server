require 'bcrypt'

MAX_OTP_RESEND_COUNT = 3

class SignupController < ApiController
    
    def do
        
        name = params["name"]
        phone_number = params["phone_number"]
        userExists = false

        unverifiedUser = User.where(:uid => phone_number, :verified => false).first
        if unverifiedUser != nil
            prune_old_tokens(unverifiedUser)
            if unverifiedUser.auth == nil
                unverifiedUser.delete()
            else
                userExists = true
            end
        end

        otp = 6.times.map { rand(0..9) }.join
        
        if userExists
            salt = unverifiedUser.salt
            if unverifiedUser.login_code != nil
                otp = unverifiedUser.login_code
            else
                unverifiedUser.login_code = otp
            end
        else
            salt = BCrypt::Engine.generate_salt
        end

        send_otp(otp, phone_number)
        login_token = Digest::MD5.hexdigest(BCrypt::Engine.hash_secret(otp, salt))

        if userExists
            otp_count = 0
            if unverifiedUser.otp_count != nil
                otp_count = unverifiedUser.otp_count
            end
            otp_count = otp_count + 1
            unverifiedUser.otp_count = otp_count
            if otp_count > MAX_OTP_RESEND_COUNT
                render :json => {
                    message: "You have exceeded OTP resend limit"
                }, status: 403
                return
            end
        end

        if userExists
            unverifiedUser.save()
        else
            newUser = User.new(:name => name, :uid => phone_number, :verified => false, :login_code => otp, :auth => login_token, :salt => salt)
            newUser.save()
        end

        render :json => {
            message: 'OTP sent',
            token: login_token
        }, status: 200
        return
    end

    def send_otp(otp, phone_number)
        require 'net/http'
        
        uri = URI.parse("http://api.msg91.com/api/v2/sendsms")
        
        http = Net::HTTP.new(uri.host, uri.port)
        req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
        req['authkey'] = Rails.application.secrets.MSG91_AUTH_KEY
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
            return
        else
            render :json => {
                message: "Incorrect OTP or token"
            }, status: 401
            return
        end
    end

    def resend_otp
        phone_number = params["phone_number"]
        login_token = params["login_token"]
        
        user = User.where(:uid => phone_number, :auth => login_token).first

        if user != nil
            if user.otp_count == nil
                user.otp_count = 0 
            end
            if user.otp_count < MAX_OTP_RESEND_COUNT
                user.otp_count = user.otp_count + 1
                user.save()

                send_otp(user.login_code, user.uid)
                
                render :json => {
                    message: "OTP sent",
                    attempts_left: MAX_OTP_RESEND_COUNT - user.otp_count
                }, status: 200
            else
                render :json => {
                    message: "You have exceeded OTP resend limit"
                }, status: 403
                return
            end
        else
            render :json => {
                message: "Phone number or login token invalid"
            }, status: 404
            return
        end     
    end

    def prune_old_tokens(user) 
        if !user.verified
            hours = (Time.parse(DateTime.now.to_s) - Time.parse(user.updated_at.to_s)) / 3600
            if hours >= 24 
                user.auth = nil
                user.login_code = nil
                user.otp_count = nil
                user.save()            
            end
        end
    end
end
