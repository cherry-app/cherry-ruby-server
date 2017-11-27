require 'net/http'

class MessageController < AuthenticatedApiController

    def seen
        
    end

    def publish
        senderId = request.headers["Cherry-UID"]
        failedMessages = []
        successMessages = []
        codes = []
        params["messages"].each do |msg|
            messageId = msg["id"]
            recipientId = msg["recipientId"]
            sentTime = msg["sentTime"]
            content = msg["content"]
            recipientUser = User.where(:uid => recipientId, :verified => true).first
            result = false
            response_code = 'nil'
            if recipientUser != nil
                response_code = send_fcm_message(recipientUser.fcm_token, senderId, sentTime, content)
                if response_code == '200'
                    result = true
                end
            end
            codes << response_code
            if result == true
                successMessages << messageId
            else
                failedMessages << messageId
            end
        end
        render json: {
            code: codes,
            key: "key=" + Rails.application.secrets.FCM_SERVER_KEY,
            succeeded: successMessages,
            failed: failedMessages
          }, status:200
    end

    def send_fcm_message(token, senderId, timestamp, content)
        
        uri = URI.parse('https://fcm.googleapis.com/fcm/send')
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
        req['Authorization'] = "key=" + Rails.application.secrets.FCM_SERVER_KEY
        
        req.set_form_data({
            to: token,
            data: {
                senderId: senderId,
                sentTime: timestamp,
                content: content
            }
        })

        success = false
        res = http.request(req)
        res.code
    end

    def update_fcm_token
        fcm_token = params["fcm_token"]
        senderId = request.headers["Cherry-UID"]
        
        user = User.where(:uid => senderId, :verified => true).first

        if user != nil
            user.fcm_token = fcm_token
            user.save() 
            render :json => {
                message: "Token updated"
            }, status: 200
        else
            render :json => {
                message: "User not found"
            }, status: 404
            
        end
    end

end
