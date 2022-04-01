module ApiHelper
    require 'net/https'

    # 教师通讯录同步
    def self.jdy_account_sync
        # 简道云api
        data_url = "https://api.jiandaoyun.com/api/v2/app/624275afe9e5d20009925d52/entry/6242a168785a0d000730dbe3/data"
        data_create_url = "https://api.jiandaoyun.com/api/v1/app/624275afe9e5d20009925d52/entry/6242a168785a0d000730dbe3/data_batch_create"
        data_update_url = "https://api.jiandaoyun.com/api/v3/app/624275afe9e5d20009925d52/entry/6242a168785a0d000730dbe3/data_update"
        data_delete_url = "https://api.jiandaoyun.com/api/v1/app/624275afe9e5d20009925d52/entry/6242a168785a0d000730dbe3/data_delete"
        start_time = Time.new
        Rails.logger.info("-> start jdy_account_sync at #{start_time}")
        # 1.新增数据=本地数据ids-简道云ids
        jdy_data, jdy_data_ids, jdy_data_mapping = get_jdy_data(data_url)
        local_data, local_data_ids = get_local_data(Account.all)
        # 执行新增
        jdy_data_create(data_create_url, local_data, local_data_ids - jdy_data_ids)
        # 2.更新数据=本地数据-简道云
        jdy_data, jdy_data_ids, jdy_data_mapping = get_jdy_data(data_url)
        local_data, local_data_ids = get_local_data(Account.all)
        # 执行更新
        jdy_data_update(data_update_url, local_data - jdy_data, jdy_data_mapping)
        # 3.删除数据=简道云-本地数据
        jdy_data, jdy_data_ids, jdy_data_mapping = get_jdy_data(data_url)
        local_data, local_data_ids = get_local_data(Account.all)
        # 执行删除
        jdy_data_delete(data_delete_url, jdy_data - local_data, jdy_data_mapping)
        end_time = Time.new
        time = end_time - start_time
        Rails.logger.info("-> end jdy_account_sync at #{end_time}, use_time #{time}")
        puts "jdy_account_sync at #{end_time} -> #{end_time}, use_time #{time}"
    end

    def self.jdy_student_users_sync
    end

    private
        # 简道云POST请求
        def self.jdy_post(url, data)
            # application/json
            url = URI(url)
            http = Net::HTTP.new(url.host, url.port)
            # 设置https
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            # 设置请求参数
            data = data.to_json
            # 设置请求头
            header = {'content-type':'application/json', 'Authorization':'Bearer kvaKul0ru7iakgLk7lfC3KZ4vyKuMs4R'}
            # 响应
            response = http.post(url, data, header)
            JSON.parse(response.body)
        end

        # 查询所有本地用户+ids
        def self.get_local_data(local_data)
            datalist = Array.new()
            dataids = Array.new()
            local_data.each do |local|
                data = {
                    userid: local[:userid],
                    name: local[:name],
                    department: local[:department],
                    position: local[:position],
                    mobile: local[:mobile],
                    gender: local[:gender]
                }
                dataid = { userid: local[:userid] }
                datalist << data
                dataids << dataid
            end
            return datalist, dataids
        end
        # 查询所有简道云用户+ids+用户id映射
        def self.get_jdy_data(data_url)
            datalist = Array.new()
            dataids = Array.new()
            datamapping = {}
            jdy_data = jdy_post(data_url,{ "limit": 100000 })["data"]
            jdy_data.each do |jdy|
                data = {
                    userid: jdy["_widget_1648533913709"],
                    name: jdy["_widget_1648533913728"],
                    department: jdy["_widget_1648533913747"],
                    position: jdy["_widget_1648533913766"],
                    mobile: jdy["_widget_1648533913785"],
                    gender: jdy["_widget_1648533913804"]
                }
                dataid = { userid: jdy["_widget_1648533913709"] }
                datalist << data
                dataids << dataid
                datamapping.store(jdy["_widget_1648533913709"].to_sym, jdy["_id"])
            end
            return datalist, dataids, datamapping
        end

        # 新增所有简道云用户-格式处理过
        def self.jdy_data_create(data_create_url, local_data, dataids)
            Rails.logger.info("create #{dataids.size}")
            datalist = Array.new()
            # 根据ids查找新增的数据
            dataids.each do |dataid|
                data = local_data.select { |local| local[:userid] == dataid[:userid] }
                datalist << data.first
            end
            datalist = datalist.each_slice(100).to_a
            datatmp = Array.new()
            datalist.each do | data |
                data.each do | da |
                    data = {
                        "_widget_1648533913709": { "value": da[:userid] },
                        "_widget_1648533913728": { "value": da[:name] },
                        "_widget_1648533913747": { "value": da[:department] },
                        "_widget_1648533913766": { "value": da[:position] },
                        "_widget_1648533913785": { "value": da[:mobile] },
                        "_widget_1648533913804": { "value": da[:gender] } 
                    }   
                    datatmp << data
                end
                jdy_post(data_create_url, { "data_list":datatmp })
                datatmp.clear
            end
        end
        # 更新简道云用户
        def self.jdy_data_update(data_update_url, update_data, mapping)
            Rails.logger.info("update #{update_data.size}")
            # p data_update.first
            update_data.each do |update|
                data = { 
                    "data_id": mapping[update[:userid].to_sym],
                    "data": {
                        "_widget_1648533913728": { "value": update[:name] },
                        "_widget_1648533913709": { "value": update[:userid] },
                        "_widget_1648533913747": { "value": update[:department] },
                        "_widget_1648533913766": { "value": update[:position] },
                        "_widget_1648533913785": { "value": update[:mobile] },
                        "_widget_1648533913804": { "value": update[:gender] }
                    }
                }
                jdy_post(data_update_url, data)
            end
        end
        # 删除简道云用户
        def self.jdy_data_delete(data_delete_url, delete_data, mapping)
            Rails.logger.info("delete #{delete_data.size}")
            delete_data.each do |delete|
                data = { 
                    "data_id": mapping[delete[:userid].to_sym],
                    "data": {
                        "_widget_1648533913728": { "value": delete[:name] },
                        "_widget_1648533913709": { "value": delete[:userid] },
                        "_widget_1648533913747": { "value": delete[:department] },
                        "_widget_1648533913766": { "value": delete[:position] },
                        "_widget_1648533913785": { "value": delete[:mobile] },
                        "_widget_1648533913804": { "value": delete[:gender] }
                    }
                }
                jdy_post(data_delete_url, data)
            end
        end
end