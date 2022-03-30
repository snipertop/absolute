module ApiHelper
    require 'net/https'

    def self.jdy_account_sync
        start_time = Time.new
        puts "同步数据开始：#{start_time}"
        # 1.新增数据=本地数据ids-简道云ids
        jdy_account_create(get_accounts_create)
        # 2.更新数据=本地数据-简道云
        jdy_accounts, jdy_accounts_mapping = get_jdy_accounts
        jdy_accounts_update(get_local_accounts - jdy_accounts, jdy_accounts_mapping)
        # 3.删除数据=简道云-本地数据
        jdy_accounts, jdy_accounts_mapping = get_jdy_accounts
        jdy_accounts_delete(jdy_accounts - get_local_accounts, jdy_accounts_mapping)
        end_time = Time.new
        time = end_time - start_time
        puts "同步数据结束：#{end_time}，用时：#{time}"
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
        # 查询简道云所有用户
        def self.jdy_accounts_retrieve
            url = "https://api.jiandaoyun.com/api/v2/app/624275afe9e5d20009925d52/entry/6242a168785a0d000730dbe3/data"
            data = {"limit": 3000}
            jdy_post(url,data)["data"]
        end
        # 查询所有本地用户id
        def self.get_local_userids
            userids = Array.new()
            Account.all.each do |account|
                userid = {
                    userid: account[:userid]
                }
                userids << userid
            end
            userids
        end
        # 查询所有简道云用户id
        def self.get_jdy_userids
            userids = Array.new()
            jdy_accounts_retrieve.each do |account|
                userid = {
                    userid: account["_widget_1648533913709"]
                }
                userids << userid
            end
            userids
        end
        # 查询所有本地用户
        def self.get_local_accounts
            accounts = Array.new()
            Account.all.each do |account|
                data = {
                    userid: account[:userid],
                    name: account[:name],
                    department: account[:department],
                    position: account[:position],
                    mobile: account[:mobile],
                    gender: account[:gender],
                }
                accounts << data
            end
            accounts
        end
        # 查询所有简道云用户
        def self.get_jdy_accounts
            accounts = Array.new()
            accounts_mapping = {}
            jdy_accounts_retrieve.each do |account|
                data = {
                    userid: account["_widget_1648533913709"],
                    name: account["_widget_1648533913728"],
                    department: account["_widget_1648533913747"],
                    position: account["_widget_1648533913766"],
                    mobile: account["_widget_1648533913785"],
                    gender: account["_widget_1648533913804"],
                }
                accounts << data
                accounts_mapping.store(account["_widget_1648533913709"].to_sym,account["_id"])
            end
            return accounts, accounts_mapping
        end

        def self.get_accounts_create
            userids = get_local_userids - get_jdy_userids
            puts "新增#{userids.size}条数据"
            accounts = Array.new()
            userids.each do |userid|
                # 待优化 except
                account = Account.find_by(userid: userid[:userid])
                data = { 
                    userid: account["userid"],
                    name: account["name"],
                    department: account["department"],
                    position: account["position"],
                    mobile: account["mobile"],
                    gender: account["gender"]
                }
                accounts << data
            end
            accounts
        end
        # 更新简道云用户
        def self.jdy_accounts_update(accounts, mapping)
            puts "更新#{accounts.size}条数据"
            url = "https://api.jiandaoyun.com/api/v3/app/624275afe9e5d20009925d52/entry/6242a168785a0d000730dbe3/data_update"
            accounts.each do |account|
                data = { 
                    "data_id": mapping[account[:userid].to_sym],
                    "data": {
                        "_widget_1648533913728": { "value": account[:name] },
                        "_widget_1648533913709": { "value": account[:userid] },
                        "_widget_1648533913747": { "value": account[:department] },
                        "_widget_1648533913766": { "value": account[:position] },
                        "_widget_1648533913785": { "value": account[:mobile] },
                        "_widget_1648533913804": { "value": account[:gender] }
                    }
                }
                jdy_post(url, data)
            end
        end
        # 删除简道云用户
        def self.jdy_accounts_delete(accounts, mapping)
            puts "删除#{accounts.size}条数据"
            url = "https://api.jiandaoyun.com/api/v1/app/624275afe9e5d20009925d52/entry/6242a168785a0d000730dbe3/data_delete"
            accounts.each do |account|
                data = { 
                    "data_id": mapping[account[:userid].to_sym],
                    "data": {
                        "_widget_1648533913728": { "value": account[:name] },
                        "_widget_1648533913709": { "value": account[:userid] },
                        "_widget_1648533913747": { "value": account[:department] },
                        "_widget_1648533913766": { "value": account[:position] },
                        "_widget_1648533913785": { "value": account[:mobile] },
                        "_widget_1648533913804": { "value": account[:gender] }
                    }
                }
                jdy_post(url, data)
            end
        end
        # 新增所有简道云用户-格式处理过
        def self.jdy_account_create(accounts)
            return if accounts.empty?
            url = "https://api.jiandaoyun.com/api/v1/app/624275afe9e5d20009925d52/entry/6242a168785a0d000730dbe3/data_batch_create"
            data_list = Array.new()
            accounts = accounts.each_slice(100).to_a
            accounts.each do | acc |
                acc.each do | ac |
                    account = {
                        "_widget_1648533913709": { "value": ac[:userid] },
                        "_widget_1648533913728": { "value": ac[:name] },
                        "_widget_1648533913747": { "value": ac[:department] },
                        "_widget_1648533913766": { "value": ac[:position] },
                        "_widget_1648533913785": { "value": ac[:mobile] },
                        "_widget_1648533913804": { "value": ac[:gender] } 
                    }   
                    data_list << account
                end
                jdy_post(url, { "data_list":data_list })
                data_list.clear
            end
        end
end