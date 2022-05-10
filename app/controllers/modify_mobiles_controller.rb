class ModifyMobilesController < ApplicationController
  before_action :set_modify_mobile, only: %i[ show edit update destroy ]

  def auth
    # url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=wwf8d912afaf40628a&redirect_uri=http://zbu.free.svipss.top/modify_mobiles/callback&response_type=code&scope=snsapi_base#wechat_redirect"
    url = "https://open.weixin.qq.com/connect/oauth2/authorize?appid=wwf8d912afaf40628a&redirect_uri=http://xxk.zbu.edu.cn:3032/modify_mobiles/callback&response_type=code&scope=snsapi_base#wechat_redirect"
    redirect_to(url, allow_other_host: true)    
  end

  def callback
    access_token = WexinUserHelper.wexin_access_token
    userid_url = URI('https://qyapi.weixin.qq.com/cgi-bin/user/getuserinfo?access_token=' + access_token + '&code=' + params[:code])
    response = Net::HTTP.get_response(userid_url)
    cookies[:userid] = JSON.parse(response.body)["UserId"]
    redirect_to(modify_mobiles_path)    
  end

  def complete
    @modify_mobiles = ModifyMobile.where({status: "1"}) # 0:未审核，1:已审核
  end

  # GET /modify_mobiles or /modify_mobiles.json
  def index
    userlist = ["1703018","1703017"]
    if userlist.include?(cookies[:userid])
      @modify_mobiles = ModifyMobile.where({status: "0"}) # 0:未审核，1:已审核
    else
      render "modify_mobiles/new"
    end
  end

  # GET /modify_mobiles/1 or /modify_mobiles/1.json
  def show
  end

  # GET /modify_mobiles/new
  def new
    @modify_mobile = ModifyMobile.new
  end

  # GET /modify_mobiles/1/edit
  def edit
  end

  def create
    # 请求参数
    p_userid = modify_mobile_params[:userid]
    p_name = modify_mobile_params[:name]
    p_mobile = modify_mobile_params[:mobile]
    p_idnumber = modify_mobile_params[:idnumber]
    pattern = /^(13[0-9]|14[01456879]|15[0-35-9]|16[2567]|17[0-8]|18[0-9]|19[0-35-9])\d{8}$/
    if p_userid.empty? or p_name.empty? or p_mobile.empty? or p_idnumber.empty? or (p_mobile =~ pattern).nil?
      respond_to do |format|
        format.turbo_stream do 
          render turbo_stream:
            turbo_stream.update("flash", partial: "modify_mobiles/flash", locals: { warn: "信息提交失败！" })
        end
      end
      return
    end
    # 认证平台数据
    r_user = WexinUserHelper.rz_user(p_userid)
    if r_user["data"] == "uid无效"
      respond_to do |format|
        format.turbo_stream do 
          render turbo_stream:
            turbo_stream.update("flash", partial: "modify_mobiles/flash", locals: { warn: "信息提交失败！" })
        end
      end
      return
    end
    r_name = r_user["data"]["cn"].first
    r_userid = r_user["data"]["uid"].first
    r_mobile = r_user["data"]["telephoneNumber"].first[-11,11]
    r_idnumber = r_user["data"]["eduPersonCardID"].first[-6,6]
    r_status = r_user["data"]["status"].first
    if r_status == "1"
      r_status = "已激活"
    else
      r_status = "未激活"
    end
    # 本地数据
    if StudentUser.where({userid: p_userid}).empty?
      respond_to do |format|
        format.turbo_stream do 
          render turbo_stream:
            turbo_stream.update("flash", partial: "modify_mobiles/flash", locals: { warn: "仅支持学生提交！" })
        end
      end
      return
    end
    # 微信平台数据
    w_user = WexinUserHelper.wexin_user(p_userid)
    w_mobile = w_user["mobile"]
    w_status = w_user["status"]
    if w_status == 1
      w_status = "已激活"
    elsif w_status == 2
      w_status = "已禁用"
    elsif w_status == 4
      w_status = "未激活"
    elsif w_status == 5
      w_status = "退出企业"
    end
    # 认证和请求对比
    p_string = p_userid + p_name + p_idnumber
    r_string = r_userid + r_name + r_idnumber
    if p_string == r_string
      modify_mobile = {
        "userid": modify_mobile_params["userid"],
        "name": modify_mobile_params["name"],
        "mobile": modify_mobile_params["mobile"],
        "idnumber": modify_mobile_params["idnumber"],
        "status": "0",
        "wx_mobile": w_mobile,
        "wx_status": w_status,
        "rz_mobile": r_mobile,
        "rz_status": r_status,
      }
      @modify_mobile = ModifyMobile.new(modify_mobile)
      respond_to do |format|
        if @modify_mobile.save
          format.turbo_stream do 
            render turbo_stream: [
              turbo_stream.update("flash", partial: "modify_mobiles/flash", locals: { notice: "信息提交成功！" })
          ]
          end
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do 
          render turbo_stream:
            turbo_stream.update("flash", partial: "modify_mobiles/flash", locals: { warn: "信息提交失败！" })
        end
      end
    end
  end

  # POST /modify_mobiles or /modify_mobiles.json
  def create_bak
      @modify_mobile = ModifyMobile.new(modify_mobile_params)
      respond_to do |format|
        if @modify_mobile.save
          format.html { redirect_to modify_mobile_url(@modify_mobile), flash: "Modify mobile was successfully created." }
          format.json { render :show, status: :created, location: @modify_mobile }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @modify_mobile.errors, status: :unprocessable_entity }
        end
      end
  end

  # PATCH/PUT /modify_mobiles/1 or /modify_mobiles/1.json
  def update  
    update_data = {
      userid: @modify_mobile["userid"],
      mobile: @modify_mobile["mobile"],
    }
    # 更新微信
    access_token = WexinUserHelper.wexin_access_token
    if @modify_mobile["wx_status"] == "未激活"
      wexin_user_update_url = "https://qyapi.weixin.qq.com/cgi-bin/user/update?access_token=" + access_token
      wx_code = WexinUserHelper.wexin_post(wexin_user_update_url, update_data)
      if wx_code != 0
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.update("flash", partial: "modify_mobiles/flash", locals: { warn: "企业微信手机号修改失败！" }) } 
        end
        return
      end
    elsif @modify_mobile["wx_status"] == "已激活"
      # 构建用户信息
      w_user = WexinUserHelper.wexin_user(@modify_mobile["userid"])
      data = {
        userid: w_user["userid"],
        name: w_user["name"],
        department: w_user["department"],
        position: w_user["position"],
        mobile: @modify_mobile["mobile"],
        gender: w_user["gender"]
      }
      # 删除用户
      wexin_user_delete_url = "https://qyapi.weixin.qq.com/cgi-bin/user/delete?access_token=" + access_token + "&userid="
      WexinUserHelper.wexin_get(wexin_user_delete_url + @modify_mobile["userid"])
      # 新增用户
      wexin_user_create_url = "https://qyapi.weixin.qq.com/cgi-bin/user/create?access_token=" + access_token
      wx_code = WexinUserHelper.wexin_post(wexin_user_create_url, data)
      puts wx_code
      if wx_code != 0
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.update("flash", partial: "modify_mobiles/flash", locals: { warn: "企业微信手机号修改失败！" }) } 
        end
        return
      end
    end
    # 更新认证
    rz_code = WexinUserHelper.rz_post(update_data)
    if rz_code != "1"
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.update("flash", partial: "modify_mobiles/flash", locals: { warn: "一网通办手机号修改失败！" }) } 
      end
      return
    end
    modify_mobile = {
      "id": @modify_mobile["id"],
      "status": "1",
      "reviewer": cookies[:userid],
      "wx_mobile": @modify_mobile["mobile"],
      "rz_mobile": @modify_mobile["mobile"],
    }
    respond_to do |format|
      if @modify_mobile.update(modify_mobile)
        format.turbo_stream do 
          render turbo_stream: [
            turbo_stream.update("flash", partial: "modify_mobiles/flash", locals: { notice: "修改成功！" }),
            turbo_stream.remove(@modify_mobile)
        ]
        end
      else
        format.turbo_stream do 
          render turbo_stream:
            turbo_stream.update("flash", partial: "modify_mobiles/flash", locals: { warn: "修改失败！" })
        end
      end
    end
  end

  # DELETE /modify_mobiles/1 or /modify_mobiles/1.json
  def destroy
    @modify_mobile.destroy

    respond_to do |format|
      format.turbo_stream do 
        render turbo_stream:[
          turbo_stream.update("flash", partial: "modify_mobiles/flash", locals: { notice: "删除成功！" }),
          turbo_stream.remove(@modify_mobile)
        ]
      end
      format.html { redirect_to modify_mobiles_url, flash: "Modify mobile was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private 
    # Use callbacks to share common setup or constraints between actions.
    def set_modify_mobile
      @modify_mobile = ModifyMobile.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def modify_mobile_params
      params.require(:modify_mobile).permit(:userid, :name, :mobile, :idnumber, :status, :reviewer, :wx_mobile, :wx_status, :rz_mobile, :rz_status)
    end
end