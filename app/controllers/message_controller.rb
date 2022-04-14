class MessageController < ApplicationController
    include MessageHelper
    skip_before_action :verify_authenticity_token, :only => :msg

    def msg
        payload = params[:data]
        return if payload.empty?
        to = payload["to"]
        title = payload["notify_text"]
        content = payload["entry_name"]
        url = payload["url"]
        send_message(to, title, content, url)
    end
end
