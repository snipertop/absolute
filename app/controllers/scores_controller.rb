class ScoresController < ApplicationController

    def auth
        # url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=wwf8d912afaf40628a&redirect_uri=http://zbu.free.svipss.top/scores/callback&response_type=code&scope=snsapi_base#wechat_redirect"
        url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=wwf8d912afaf40628a&redirect_uri=http://xxk.zbu.edu.cn:3032/scores/callback&response_type=code&scope=snsapi_base#wechat_redirect"
        if cookies[:userid].nil?
          # Rails.logger.info("no use cookie #{ cookies[:userid ]}")
          redirect_to(url, allow_other_host: true)
        else
          # Rails.logger.info("use cookie #{ cookies[:userid ]}")
          redirect_to(scores_path)
        end
      end
    
      def callback
        corpsecret = "aY_ZzMmKM5jsqUcTOBDFwz3ftnk7QZevSBUbCJYBWIU" #考试成绩
        # corpsecret = "4Ip0AbKz5wQ8nkpPth9v6Pt8lYEpng5ZpXYPlToxaVY" #二维码测试
        access_token_url = URI("https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=wwf8d912afaf40628a&corpsecret=" + corpsecret)
        response = Net::HTTP.get_response(access_token_url)
        access_token = JSON.parse(response.body)["access_token"]
        userid_url = URI('https://qyapi.weixin.qq.com/cgi-bin/user/getuserinfo?access_token=' + access_token + '&code=' + params[:code])
        response = Net::HTTP.get_response(userid_url)
        cookies[:userid] = JSON.parse(response.body)["UserId"]
        redirect_to(scores_path)    
      end

    def index
        # userid = cookies[:userid]
        userid = "20190141137"
        user_scores = Score.where({user_xh: userid}).to_a
        # 处理学年
        xn_list = Array.new()
        user_scores.each do |user_score|
            xn_list << user_score[:xn]
        end
        xn_list = xn_list.uniq.sort!.reverse
        xn_2 = Array.new()
        xn_list.each do |xn|
            xn_1 = Array.new()
            2.times { xn_1 << xn }
            xn_2 << xn_1
        end
        xn = params[:xn]
        xq = params[:xq]
        if xn.nil? and xq.nil?
            @xn_selected = xn_list.first
            @xq_selected = "0"
        else
            @xn_selected = xn
            @xq_selected = xq
        end
        @xn_list = xn_2
        @scores = Score.where({user_xh: userid, xn: xn, xq: xq})
    end

end