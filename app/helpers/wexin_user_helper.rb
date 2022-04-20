module WexinUserHelper

    # 企业微信通讯录同步
    def self.wexin_user_sync
        start_time = Time.new
        Rails.logger.info("-> start wexin_user_sync at #{start_time}")
        access_token = wexin_access_token
        # 企业微信用户
        wexin_user_url = "https://qyapi.weixin.qq.com/cgi-bin/user/list?access_token=" + access_token + "&department_id=128&fetch_child=1"
        # 企业微信部门
        wexin_department_url = "https://qyapi.weixin.qq.com/cgi-bin/department/list?access_token=" + access_token + "&id=128"
        # 企业微信新增
        wexin_user_create_url = "https://qyapi.weixin.qq.com/cgi-bin/user/create?access_token=" + access_token
        local_user_create, local_userids_create = local_user_list(StudentUser.all, wexin_get(wexin_department_url)["department"])
        wexin_user_create, wexin_userids_create = wexin_user_list(access_token, wexin_get(wexin_user_url)["userlist"])
        wexin_user_create(wexin_user_create_url, local_user_create, local_userids_create - wexin_userids_create)
        # 企业微信删除
        wexin_user_delete_url = "https://qyapi.weixin.qq.com/cgi-bin/user/delete?access_token=" + access_token + "&userid="
        local_user_delete, local_userids_delete = local_user_list(StudentUser.all, wexin_get(wexin_department_url)["department"])
        wexin_user_delete, wexin_userids_delete = wexin_user_list(access_token, wexin_get(wexin_user_url)["userlist"])
        wexin_user_delete(wexin_user_delete_url, wexin_userids_delete - local_userids_delete)
        # 企业微信更新
        wexin_user_update_url = "https://qyapi.weixin.qq.com/cgi-bin/user/update?access_token=" + access_token
        local_user_update, local_userids_update = local_user_list(StudentUser.all, wexin_get(wexin_department_url)["department"])
        wexin_user_update, wexin_userids_update = wexin_user_list(access_token, wexin_get(wexin_user_url)["userlist"])
        wexin_user_update(wexin_user_update_url, local_user_update - wexin_user_update)
        # 认证平台更新
        end_time = Time.new
        time = end_time - start_time
        Rails.logger.info("-> end wexin_user_sync at #{end_time}, use_time #{time}")
        puts "wexin_user_sync at #{start_time} -> #{end_time}, use_time #{time}"
    end

    private
        def self.wexin_access_token
            corpsecret = "1Gawl5gRSuwnYKxGG-040qQNlwD0jkaFZICzyWC0dwQ"
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
            JSON.parse(response.body)["errmsg"]
        end

        # 企业微信GET请求
        def self.wexin_get(url)
            url = URI(url)
            response = Net::HTTP.get_response(url)
            JSON.parse(response.body)
        end

        # 查询本地学生数据
        def self.local_user_list(studentlist, departmentlist)
            datalist = Array.new()
            dataids = Array.new()
            studentlist.each do |student|
                next if student[:mobile].nil?
                department = departmentlist.select { |department| department["name"] == student[:classes] }
                departmentid = department.first["id"].to_i unless department.first.nil?
                gender = student[:gender]=="男" ? "1" : "2" 
                data = {
                    "userid": student[:userid],
                    "name": student[:name],
                    "department": [departmentid],
                    "position": "",
                    "mobile": student[:mobile],
                    "gender": gender
                }
                datalist << data
                dataids << student[:userid]
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
            Rails.logger.info("create #{userids.size}")
            userids.each do |userid|
                data = userlist.select { |user| user[:userid] == userid }
                cur_time = Time.new
                wexin_post(user_create_url, data.first)
                cur_time = Time.new - cur_time
                sleep(300) if cur_time > 5
            end
        end

        # 删除简道云用户
        def self.wexin_user_delete(user_delete_url, userids)
            Rails.logger.info("delete #{userids.size}")
            userids.each do |userid|
                cur_time = Time.new
                wexin_get(user_delete_url + userid)
                cur_time = Time.new - cur_time
                sleep(300) if cur_time > 5
            end
        end

        # 更新企业微信数据用户
        def self.wexin_user_update(user_update_url, userlist)
            Rails.logger.info("update #{userlist.size}")
            userlist.each do |user|
                cur_time = Time.new
                wexin_post(user_update_url, user)
                cur_time = Time.new - cur_time
                sleep(300) if cur_time > 5
            end
        end
end
