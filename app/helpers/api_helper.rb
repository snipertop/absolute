module ApiHelper
    require 'net/https'

    def jdy_account_sync
        # 1.新增数据=本地数据-简道云
        jdy_account_create(get_accounts_create)
        # 2.更新删除数据=简道云循环查询本地数据，查询是：更新；查询否：删除
        jdy_accounts_update
    end

    private
        # 简道云POST请求
        def jdy_post(url, data)
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
        def jdy_accounts_retrieve
            url = "https://api.jiandaoyun.com/api/v2/app/624275afe9e5d20009925d52/entry/6242a168785a0d000730dbe3/data"
            data = {"limit": 3000}
            jdy_post(url,data)["data"]
        end
        # 查询所有本地用户id
        def get_local_userids
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
        def get_jdy_userids
            userids = Array.new()
            jdy_accounts_retrieve.each do |account|
                userid = {
                    userid: account["_widget_1648533913709"]
                }
                userids << userid
            end
            userids
        end
        def get_accounts_create
            userids = get_local_userids - get_jdy_userids
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
        # 更新所有简道云用户+删除
        def jdy_accounts_update
            jdy_accounts_retrieve.each do |account|
                local_account = Account.find_by(userid: account["_widget_1648533913709"])
                if local_account
                    # 更新
                    url = "https://api.jiandaoyun.com/api/v3/app/624275afe9e5d20009925d52/entry/6242a168785a0d000730dbe3/data_update"
                    data = { 
                        "data_id": account["_id"],
                        "data": {
                            "_widget_1648533913709": { "value": local_account[:userid] },
                            "_widget_1648533913728": { "value": local_account[:name] },
                            "_widget_1648533913747": { "value": local_account[:department] },
                            "_widget_1648533913766": { "value": local_account[:position] },
                            "_widget_1648533913785": { "value": local_account[:mobile] },
                            "_widget_1648533913804": { "value": local_account[:gender] }
                        }
                    }
                    jdy_post(url, data)
                else
                    # 删除
                    url = "https://api.jiandaoyun.com/api/v1/app/624275afe9e5d20009925d52/entry/6242a168785a0d000730dbe3/data_delete"
                    data = { "data_id": account["_id"] }
                    jdy_post(url, data)
                end
            end
        end
        # 新增所有简道云用户-格式处理过
        def jdy_account_create(accounts)
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