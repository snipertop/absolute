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

{
    "data"=>{
        "content"=>"", 
        "entry_name"=>"重置密码", 
        "flow_action"=>"flow_forward", 
        "notify_text"=>"有新的流程待办事项", 
        "to"=>[{"name"=>"阮琳赈", "username"=>"1703018"}, {"name"=>"耿中宝", "username"=>"1703017"}], 
        "url"=>"https://www.jiandaoyun.com/dashboard/app/621c17b51f2b340007faa95b/form/621c17ba218da2000858fcff/data/62576229ee502d0008487cd0?actionType=flow_forward&flowId=1&memberType=0&guestCorpId="
        }, 
        "op"=>"flow_message", 
        "send_time"=>"2022-04-13T23:52:09.597Z", 
        "nonce"=>"956f23", 
        "timestamp"=>"1649893929", 
        "message"=>{"data"=>{"content"=>"", "entry_name"=>"重置密码", "flow_action"=>"flow_forward", "notify_text"=>"有新的流程待办事项", "to"=>[{"name"=>"阮琳赈", "username"=>"1703018"}, {"name"=>"耿中宝", "username"=>"1703017"}], "url"=>"https://www.jiandaoyun.com/dashboard/app/621c17b51f2b340007faa95b/form/621c17ba218da2000858fcff/data/62576229ee502d0008487cd0?actionType=flow_forward&flowId=1&memberType=0&guestCorpId="}, "op"=>"flow_message", "send_time"=>"2022-04-13T23:52:09.597Z"}}
