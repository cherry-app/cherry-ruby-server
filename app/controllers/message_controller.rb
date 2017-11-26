require 'fcm'

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
        fcm = FCM.new(Rails.application.secrets.FCM_SERVER_KEY)
        registration_ids = [token]
        options = {
            data: {
                senderId: senderId,
                content: content,
                sentTime: timestamp
            }
        }
        response = fcm.send(registration_ids, options)

        if response.status_code == 200
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
