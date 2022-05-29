class ApiController < ApplicationController
    require 'digest/sha1' 
    include ApiHelper
    include MessageHelper
    skip_before_action :verify_authenticity_token, :only => :msg

    def index
        # ApiHelper.jdy_account_sync
        p Post.all
    end

    def msg
        secret = "ugkevegNjX4ZMISRQKhMxm9k"
        payload = params[:data]
        nonce = params[:nonce]
        timestamp = params[:timestamp]
        get_signature(nonce, payload, secret, timestamp)
        puts '简道云'
        puts request.headers["X-JDY-Signature"]

        to = payload["to"]
        title = payload["entry_name"]
        content = payload["content"]
        url = payload["url"]

        # send_message(to, title, content, url)
    end

    def get_signature(nonce, payload, secret, timestamp)
        puts '本地'
        puts "#{nonce}:#{payload}:#{secret}:#{timestamp}"
        content = "#{nonce}:#{payload}:#{secret}:#{timestamp}".encode("utf-8")
        puts Digest::SHA1.hexdigest(content)
    end

    def sso
        # 密钥 =  TfcuDy1R3ADswElYtkAjwIhT
        # iss = com.jiandaoyun
        # HS256
        # iss=com.jiandaoyun iat=签发时间 exp=过期时间 type=sso_req
        # 解密校验参数
        secret = "TfcuDy1R3ADswElYtkAjwIhT"
        iss = "com.jiandaoyun"
        token = params[:request]
        state =  params[:state]
        begin
            decoded_token = JWT.decode token, secret, true, { iss: iss, verify_iss: true, algorithm: 'HS256' }
            puts decoded_token
        rescue JWT::ExpiredSignature, JWT::InvalidIssuerError
            puts "校验失败"
            return
        end
        # 加密登录请求
        # 签发时间
        iat = Time.now.to_i
        # 失效时间
        exp = iat + 4 * 3600
        payload = {
            aud: "com.jiandaoyun",
            exp: exp,
            iat: iat,
            type: "sso_res",
            username: "1703018",
        }
        token = JWT.encode payload, secret, 'HS256'
        redirect_to "https://www.jiandaoyun.com/sso/custom/wwf8d912afaf40628a/acs?response=#{token}&state=#{state}", allow_other_host: true
    end
end

=begin
{
    "data"=>{
        "content"=>"消息测试: 4", 
        "entry_name"=>"消息测试", 
        "flow_action"=>"flow_forward", 
        "notify_text"=>"有新的流程待办事项", 
        "to"=>[{"name"=>"阮琳赈", "username"=>"1703018"}], 
        "url"=>"https://www.jiandaoyun.com/dashboard/app/624275afe9e5d20009925d52/form/6253e2f1a144700008d03fc3/data/62561924fccabd00087edf62?actionType=flow_forward&flowId=1&memberType=0&guestCorpId="
    }, 
    "op"=>"flow_message", 
    "send_time"=>"2022-04-13T00:28:20.203Z", 
    "nonce"=>"4c9185", 
    "timestamp"=>"1649809700",
    "api"=>{
        "data"=>{
            "content"=>"消息测试: 4", 
            "entry_name"=>"消息测试", 
            "flow_action"=>"flow_forward", 
            "notify_text"=>"有新的流程待办事项", 
            "to"=>[{"name"=>"阮琳赈", "username"=>"1703018"}], 
            "url"=>"https://www.jiandaoyun.com/dashboard/app/624275afe9e5d20009925d52/form/6253e2f1a144700008d03fc3/data/62561924fccabd00087edf62?actionType=flow_forward&flowId=1&memberType=0&guestCorpId="
        }, 
        "op"=>"flow_message", 
        "send_time"=>"2022-04-13T00:28:20.203Z"
    }
}
=end