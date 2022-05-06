class WexinUserController < ApplicationController
    include WexinUserHelper

    def index
        WexinUserHelper.wexin_user_sync
    end

    def show
        # WexinUserHelper.wexin_user("1703018")
        # WexinUserHelper.rz_user("1703018")
    end

    def search
        # 请求参数
        p_userid = params[:userid]
        p_name = params[:name]
        p_mobile = params[:mobile]
        p_idnumber = params[:idnumber]
        # 微信平台数据
        w_user = WexinUserHelper.wexin_user(p_userid).to_s
        puts w_mobile = w_user["mobile"]
        # 认证平台数据
        r_user = WexinUserHelper.rz_user(p_userid)
        r_name = r_user["data"]["cn"].first
        r_userid = r_user["data"]["uid"].first
        puts r_mobile = r_user["data"]["telephoneNumber"].first.delete("86-")
        r_idnumber = r_user["data"]["eduPersonCardID"].first[-6,6]
        # 认证和请求对比
        p_string = p_userid + p_name + p_idnumber
        r_string = r_userid + r_name + r_idnumber
        if p_string == r_string
            puts "成功"
        else
            puts "失败"
            return
        end
        # 返回信息：手机号*
        respond_to do |format|
            format.turbo_stream do
                render turbo_stream: 
                    turbo_stream.update("search_results", partial: "wexin_user/search_results", locals: { w_user: w_user, r_user: r_user })
            end
        end
    end
end
