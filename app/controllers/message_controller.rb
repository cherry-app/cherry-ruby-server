require 'net/http'

class MessageController < AuthenticatedApiController

    def seen
        
    end

    def publish
        senderId = request.headers["Cherry-UID"]
        failedMessages = []
        successMessages = []
        params["messages"].each do |msg|
            messageId = msg["id"]
            recipientId = msg["recipientId"]
            sentTime = msg["sentTime"]
            content = msg["content"]
            
            recipientUser = User.where(:uid => recipientId, :verified => true).first
            result = false
            if recipientUser != nil
                result = send_fcm_message(recipientUser.fcm_token, senderId, sentTime, content)
            end
            if result == true
                successMessages << messageId
            else
                failedMessages << messageId
            end
        end
        render json: {
            succeeded: successMessages,
            failed: failedMessages
          }, status:200
    end

    def send_fcm_message(token, senderId, timestamp, content)
        
        uri = URI.parse('https://fcm.googleapis.com/fcm/send')
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
        request['Authorization'] = "key=" + Rails.application.secrets.MSG91_AUTH_KEY
        
        request.set_form_data({
            to: token,
            notification: {
                senderId: senderId,
                sentTime: timestamp,
                content: content
            }
        })

        if response.code == 200
            return true
        else
            return false
        end
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
