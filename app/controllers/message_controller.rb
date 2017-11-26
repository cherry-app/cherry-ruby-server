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
            
            token = Users.where(:uid => recipientId, :verified => true).first
            result = false
            if token != nil
                result = send_fcm_message(token, senderId, sentTime, content)
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
