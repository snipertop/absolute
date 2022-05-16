module WexinUserHelper
    require 'digest/sha1'

    #查询微信用户
    def self.wexin_user(userid)
        access_token = wexin_access_token
        wexin_user_url = "https://qyapi.weixin.qq.com/cgi-bin/user/get?access_token=" + access_token + "&userid=" + userid
        wexin_get(wexin_user_url)
    end

    def self.rz_user(uid)
        url = URI('http://10.109.10.12:9000/internal/user/getAttributes')
        http = Net::HTTP.new(url.host, url.port)
        #设置请求头
        accessToken = "6da3db56cd327dada299351ea69e4004"
        header = {'content-type':'application/x-www-form-urlencoded','appid':'f0fe8dbada0b0404','accessToken':accessToken}
        timestamp = Time.new.to_i.to_s
        str = "zbu"
        sign = Array[accessToken,timestamp, str, uid].sort.join
        sign = Digest::SHA1.hexdigest(sign)
        data = URI.encode_www_form({
            "uid": uid,
            "timeStamp": timestamp,
            "randomStr": str,
            "sign": sign
        })
        response = http.post(url, data, header)
        JSON.parse(response.body)
    end

    # 企业微信通讯录同步
    def self.wexin_user_sync
        start_time = Time.new
        Rails.logger.info("-> start wexin_user_sync at #{start_time}")
        access_token = wexin_access_token
        # 企业微信用户
        wexin_student_user_url = "https://qyapi.weixin.qq.com/cgi-bin/user/list?access_token=" + access_token + "&department_id=128&fetch_child=1"
        wexin_teacher_user_url = "https://qyapi.weixin.qq.com/cgi-bin/user/list?access_token=" + access_token + "&department_id=88&fetch_child=1"
        # 企业微信部门
        wexin_student_department_url = "https://qyapi.weixin.qq.com/cgi-bin/department/list?access_token=" + access_token + "&id=128"
        wexin_teacher_department_url = "https://qyapi.weixin.qq.com/cgi-bin/department/list?access_token=" + access_token + "&id=88"
        # 企业微信新增
        wexin_user_create_url = "https://qyapi.weixin.qq.com/cgi-bin/user/create?access_token=" + access_token
        local_student_user_create, local_student_userids_create = local_student_user_list(StudentUser.all, wexin_get(wexin_student_department_url)["department"])
        local_teacher_user_create, local_teacher_userids_create = local_teacher_user_list(TeacherUser.all, wexin_get(wexin_teacher_department_url)["department"])
        wexin_student_user_create, wexin_student_userids_create = wexin_user_list(access_token, wexin_get(wexin_student_user_url)["userlist"])
        wexin_teacher_user_create, wexin_teacher_userids_create = wexin_user_list(access_token, wexin_get(wexin_teacher_user_url)["userlist"])
        Rails.logger.info("student > ")
        wexin_user_create(wexin_user_create_url, local_student_user_create, local_student_userids_create - wexin_student_userids_create)
        Rails.logger.info("teacher > ")
        wexin_user_create(wexin_user_create_url, local_teacher_user_create, local_teacher_userids_create - wexin_teacher_userids_create)
        # 企业微信更新
        wexin_user_update_url = "https://qyapi.weixin.qq.com/cgi-bin/user/update?access_token=" + access_token
        local_student_user_update, local_student_userids_update = local_student_user_list(StudentUser.all, wexin_get(wexin_student_department_url)["department"])
        local_teacher_user_update, local_teacher_userids_update = local_teacher_user_list(TeacherUser.all, wexin_get(wexin_teacher_department_url)["department"])
        wexin_student_user_update, wexin_student_userids_update = wexin_user_list(access_token, wexin_get(wexin_student_user_url)["userlist"])
        wexin_teacher_user_update, wexin_teacher_userids_update = wexin_user_list(access_token, wexin_get(wexin_teacher_user_url)["userlist"])
        Rails.logger.info("student > ")
        wexin_user_update(wexin_user_update_url, local_student_user_update - wexin_student_user_update)
        Rails.logger.info("teacher > ")
        wexin_user_update(wexin_user_update_url, local_teacher_user_update - wexin_teacher_user_update)
        # return
        # 认证平台更新手机号
        Rails.logger.info("student > ")
        rz_mobile_update(wexin_student_user_update - local_student_user_update)
        Rails.logger.info("teacher > ")
        rz_mobile_update(wexin_teacher_user_update - local_teacher_user_update)
        # 企业微信禁用
        # wexin_user_delete_url = "https://qyapi.weixin.qq.com/cgi-bin/user/disable?access_token=" + access_token + "&userid="
        local_student_user_disable, local_student_userids_disable = local_student_user_list(StudentUser.all, wexin_get(wexin_student_department_url)["department"])
        local_teacher_user_disable, local_teacher_userids_disable = local_teacher_user_list(TeacherUser.all, wexin_get(wexin_teacher_department_url)["department"])
        wexin_student_user_disable, wexin_student_userids_disable = wexin_user_list(access_token, wexin_get(wexin_student_user_url)["userlist"])
        wexin_teacher_user_disable, wexin_teacher_userids_disable = wexin_user_list(access_token, wexin_get(wexin_teacher_user_url)["userlist"])
        Rails.logger.info("student > ")
        wexin_user_disable(wexin_user_update_url, wexin_student_userids_disable - local_student_userids_disable)
        # Rails.logger.info("teacher > ")
        # wexin_user_disable(wexin_user_update_url, wexin_teacher_userids_disable - local_teacher_userids_disable)
        end_time = Time.new
        time = end_time - start_time
        Rails.logger.info("-> end wexin_user_sync at #{end_time}, use_time #{time}")
        puts "wexin_user_sync at #{start_time} -> #{end_time}, use_time #{time}"
    end

    private
        def self.wexin_access_token
            corpsecret = "1Gawl5gRSuwnYKxGG-040qQNlwD0jkaFZICzyWC0dwQ" #通讯录同步
            access_token_url = URI("https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=wwf8d912afaf40628a&corpsecret=" + corpsecret)
            response = Net::HTTP.get_response(access_token_url)
            JSON.parse(response.body)["access_token"]
        end

        # 企业微信POST请求
        def self.wexin_post(url, data)
            url = URI(url)
            http = Net::HTTP.new(url.host, url.port)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            # 设置请求参数
            data = data.to_json  
            # 设置请求头
            header = {'content-type':'application/json'}
            response = http.post(url, data, header)
            response.body
            JSON.parse(response.body)["errcode"]
        end

        # 企业微信GET请求
        def self.wexin_get(url)
            url = URI(url)
            response = Net::HTTP.get_response(url)
            JSON.parse(response.body)
        end

        # 认证POST请求
        def self.rz_post(user)
            url = URI('http://10.109.10.12:9000/internal/user/updateAttributes')
            http = Net::HTTP.new(url.host, url.port)
            #设置请求头
            accessToken = "6da3db56cd327dada299351ea69e4004"
            header = {'content-type':'application/x-www-form-urlencoded','appid':'f0fe8dbada0b0404','accessToken':accessToken}
            timestamp = Time.new.to_i.to_s
            str = "zbu"
            uid = user[:userid]
            mobile = "{\"telephoneNumber\":\"#{user[:mobile]}\"}"
            sign = Array[accessToken,timestamp, str, uid + mobile].sort.join
            sign = Digest::SHA1.hexdigest(sign)
            data = URI.encode_www_form({
                "uid": uid,
                "timeStamp": timestamp,
                "randomStr": str,
                "sign": sign,
                "data": mobile
            })
            response = http.post(url, data, header)
            JSON.parse(response.body)["status"]
        end

        # 查询本地学生数据
        def self.local_student_user_list(studentlist, departmentlist)
            datalist = Array.new()
            dataids = Array.new()
            studentlist.each do |student|
                mobile = student[:mobile]
                pattern = /^(13[0-9]|14[01456879]|15[0-35-9]|16[2567]|17[0-8]|18[0-9]|19[0-35-9])\d{8}$/
                next if mobile.nil? or (mobile =~ pattern).nil?
                department = departmentlist.select { |department| department["name"] == student[:classes] }
                departmentid = department.first["id"].to_i unless department.first.nil?
                gender = student[:gender]=="男" ? "1" : "2" 
                data = {
                    "userid": student[:userid],
                    "name": student[:name],
                    "department": [departmentid],
                    "position": "学生",
                    "mobile": mobile,
                    "gender": gender
                }
                datalist << data
                dataids << student[:userid]
            end
            return datalist, dataids
        end

        # 查询本地老师数据
        def self.local_teacher_user_list(teacherlist, departmentlist)
            datalist = Array.new()
            dataids = Array.new()
            teacherlist.each do |teacher|
                mobile = teacher[:mobile]
                pattern = /^(13[0-9]|14[01456879]|15[0-35-9]|16[2567]|17[0-8]|18[0-9]|19[0-35-9])\d{8}$/
                next if mobile.nil? or (mobile =~ pattern).nil?
                department = departmentlist.select { |department| department["name"] == teacher[:department] }
                departmentid = department.first["id"].to_i unless department.first.nil?
                position = teacher[:position]
                position = "" if position.nil? 
                data = {
                    "userid": teacher[:userid],
                    "name": teacher[:name],
                    "department": [departmentid],
                    "position": position,
                    "mobile": mobile,
                    "gender": teacher[:gender]
                }
                datalist << data
                dataids << teacher[:userid]
            end
            return datalist, dataids
        end

        # 查询企业微信用户
        def self.wexin_user_list(access_token, userlist)
            datalist = Array.new()
            dataids = Array.new()
            userlist.each do |user|
                data = {
                    "userid": user["userid"],
                    "name": user["name"],
                    "department": user["department"],
                    "position": user["position"],
                    "mobile": user["mobile"],
                    "gender": user["gender"]
                }
                datalist << data
                dataids << user["userid"]
            end
            return datalist, dataids
        end

        # 企业微信新增用户
        def self.wexin_user_create(user_create_url, userlist, userids)
            Rails.logger.info("create wx #{userids.size}")
            userids.each do |userid|
                data = userlist.select { |user| user[:userid] == userid }
                cur_time = Time.new
                wexin_post(user_create_url, data.first)
                cur_time = Time.new - cur_time
                sleep(300) if cur_time > 5
            end
        end

        # 更新企业微信数据用户
        def self.wexin_user_update(user_update_url, userlist)
            Rails.logger.info("update wx #{userlist.size}")
            userlist.each do |user|
                cur_time = Time.new
                wexin_post(user_update_url, user)
                cur_time = Time.new - cur_time
                sleep(300) if cur_time > 5
            end
        end

         # 更新认证平台手机号
        def self.rz_mobile_update(userlist)
            Rails.logger.info("update rz #{userlist.size}")
            userlist.each do |user|
                rz_post(user)
            end
        end

        # 禁用简道云用户
        def self.wexin_user_disable(wexin_user_update_url, userids)
            Rails.logger.info("disable wx #{userids.size}")
            userids.each do |userid|
                next if userid == "0901001" or userid == "0901002"
                cur_time = Time.new
                wx_post(wexin_user_update_url, {"userid":userid, "enable":0})
                cur_time = Time.new - cur_time
                sleep(300) if cur_time > 5
            end
        end
end
