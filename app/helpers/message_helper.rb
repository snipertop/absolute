module MessageHelper
    require 'net/http'
    require 'digest/md5'

    def send_message(to, title, content, url)
        receivers = Array.new()
        to.each do |user|
            data = { "userId": user["username"] }
            receivers << data
        end
        schoolCode = "140400"
        appId = "c3d4e86fb31c6240"
        accessToken = "3cc840459ebc673fbf9bb431852907d8"
        userid = receivers.first[:userId]
        sign = Digest::MD5.hexdigest(accessToken + schoolCode + userid)
        # application/json
        uri = URI("http://apis.zbu.edu.cn/mp_message_pocket_web-mp-restful-message-send/ProxyService/message_pocket_web-mp-restful-message-sendProxyService")
        http = Net::HTTP.new(uri.host, uri.port)
        # 设置请求参数
        data = {
            "appId":"wisedu_test",
            "subject":title,
            "content":content,
            "pcUrl":url,
            "mobileUrl":url,
            "urlDesc":"查看详情",
            "sendType":0,
            "sendNow":true,
            "tagId":9011,
            "receivers":receivers,
            "schoolCode":schoolCode,
            "sign":sign
        }.to_json
        # 设置请求头
        header = {'content-type':'application/json', 'appId':appId, 'accessToken':accessToken}
        # 响应
        response = http.post(uri, data, header)
        JSON.parse(response.body)
    end
end
