class MessageController < ApplicationController
    include MessageHelper

    skip_before_action :verify_authenticity_token, :only => :msg

    def msg
        payload = params[:data]
        to = payload["to"]
        title = payload["entry_name"]
        content = payload["content"]
        url = payload["url"]
        return if to.nil? or title.nil? or content.nil? or ur.nil?
        send_message(to, title, content, url)
    end
end
