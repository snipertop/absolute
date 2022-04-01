module StudentUserHelper
    require 'net/https'

    # 教师通讯录同步
    def self.jdy_student_user_sync
        # 简道云api
        data_url = "https://api.jiandaoyun.com/api/v2/app/624275afe9e5d20009925d52/entry/624484a20d38230007fc6054/data"
        data_create_url = "https://api.jiandaoyun.com/api/v1/app/624275afe9e5d20009925d52/entry/624484a20d38230007fc6054/data_batch_create"
        data_update_url = "https://api.jiandaoyun.com/api/v3/app/624275afe9e5d20009925d52/entry/624484a20d38230007fc6054/data_update"
        data_delete_url = "https://api.jiandaoyun.com/api/v1/app/624275afe9e5d20009925d52/entry/624484a20d38230007fc6054/data_delete"
        start_time = Time.new
        Rails.logger.info("-> start jdy_student_user_sync at #{start_time}")
        # 1.新增数据=本地数据ids-简道云ids
        jdy_data_create, jdy_data_ids_create, jdy_data_mapping_create = get_jdy_data(data_url)
        local_data_create, local_data_ids_create = get_local_data(StudentUser.all)
        # 执行新增
        jdy_data_create(data_create_url, local_data_create, local_data_ids_create - jdy_data_ids_create)
        # 2.更新数据=本地数据-简道云
        jdy_data_update, jdy_data_ids_update, jdy_data_mapping_update = get_jdy_data(data_url)
        local_data_update, local_data_ids_update = get_local_data(StudentUser.all)
        # 执行更新
        jdy_data_update(data_update_url, local_data_update - jdy_data_update, jdy_data_mapping_update)
        # 3.删除数据=简道云-本地数据
        jdy_data_delete, jdy_data_ids_delete, jdy_data_mapping_delete = get_jdy_data(data_url)
        local_data_delete, local_data_ids_delete = get_local_data(StudentUser.all)
        # 执行删除
        jdy_data_delete(data_delete_url, jdy_data_delete - local_data_delete, jdy_data_mapping_delete)
        end_time = Time.new
        time = end_time - start_time
        Rails.logger.info("-> end jdy_student_user_sync at #{end_time}, use_time #{time}")
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

        # 格式化本地不规范数据
        def self.format_local_data(local_data)
            local_data.nil? ? "":local_data.strip
        end

        # 查询所有本地用户+ids
        def self.get_local_data(local_data)
            datalist = Array.new()
            dataids = Array.new()
            local_data.each do |local|
                data = {
                    userid: local[:userid], 
                    name: format_local_data(local[:name]), 
                    gender: format_local_data(local[:gender]),
                    birthday: format_local_data(local[:birthday]),
                    nation: format_local_data(local[:nation]),
                    id_number: format_local_data(local[:id_number]), 
                    political: format_local_data(local[:political]),
                    bank_card: format_local_data(local[:bank_card]),
                    mobile: format_local_data(local[:mobile]),
                    email: format_local_data(local[:email]),
                    education_system: format_local_data(local[:education_system]),
                    student_category: format_local_data(local[:student_category]),
                    cultivation_level: format_local_data(local[:cultivation_level]),
                    enter_school: format_local_data(local[:enter_school]),
                    leave_school: format_local_data(local[:leave_school]),
                    student_status: format_local_data(local[:student_status]),
                    at_school: format_local_data(local[:at_school]),
                    college: format_local_data(local[:college]),
                    major: format_local_data(local[:major]),
                    current_grade: format_local_data(local[:current_grade]),
                    classes: format_local_data(local[:classes]),
                    instructor_name: format_local_data(local[:instructor_name]),
                    instructor_id: format_local_data(local[:instructor_id]),
                    instructor_mobile: format_local_data(local[:instructor_mobile]),
                    campus: format_local_data(local[:campus]),
                    dormitory: format_local_data(local[:dormitory]),
                    room: format_local_data(local[:room]),
                    bed: format_local_data(local[:bed])
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
            jdy_data = jdy_post(data_url,{ limit: 10000 })["data"]
            while !jdy_data.empty?
                tmp = jdy_post(data_url,{ "data_id": jdy_data.last["_id"], limit: 10000 })["data"]
                jdy_data += tmp
                break if tmp.size < 10000
            end
            jdy_data.each do |jdy|
                data = {
                    userid: jdy["_widget_1648657570897"], name: jdy["_widget_1648657570878"], gender: jdy["_widget_1648657570859"],
                    birthday: jdy["_widget_1648657570840"], nation: jdy["_widget_1648657570821"], id_number: jdy["_widget_1648657570802"],
                    political: jdy["_widget_1648657570783"], bank_card: jdy["_widget_1648657570764"], mobile: jdy["_widget_1648657570745"],
                    email: jdy["_widget_1648657570726"], education_system: jdy["_widget_1648657570707"], student_category: jdy["_widget_1648657570688"],
                    cultivation_level: jdy["_widget_1648657570669"], enter_school: jdy["_widget_1648657570650"], leave_school: jdy["_widget_1648657570631"],
                    student_status: jdy["_widget_1648657570612"], at_school: jdy["_widget_1648657570593"], college: jdy["_widget_1648657570574"],
                    major: jdy["_widget_1648657570555"], current_grade: jdy["_widget_1648657570536"], classes: jdy["_widget_1648657570517"],
                    instructor_name: jdy["_widget_1648657570498"], instructor_id: jdy["_widget_1648657570479"], instructor_mobile: jdy["_widget_1648657570460"],
                    campus: jdy["_widget_1648657570441"], dormitory: jdy["_widget_1648657570422"], room: jdy["_widget_1648657570384"],
                    bed: jdy["_widget_1648657570403"]
                }
                dataid = { userid: jdy["_widget_1648657570897"] }
                datalist << data
                dataids << dataid
                datamapping.store(jdy["_widget_1648657570897"].to_sym, jdy["_id"])
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
                        "_widget_1648657570897": { "value": da[:userid] }, "_widget_1648657570878": { "value": da[:name] },
                        "_widget_1648657570859": { "value": da[:gender] }, "_widget_1648657570840": { "value": da[:birthday] },
                        "_widget_1648657570821": { "value": da[:nation] }, "_widget_1648657570802": { "value": da[:id_number] },
                        "_widget_1648657570783": { "value": da[:political] }, "_widget_1648657570764": { "value": da[:bank_card] },
                        "_widget_1648657570745": { "value": da[:mobile] }, "_widget_1648657570726": { "value": da[:email] },
                        "_widget_1648657570707": { "value": da[:education_system] }, "_widget_1648657570688": { "value": da[:student_category] },
                        "_widget_1648657570669": { "value": da[:cultivation_level] }, "_widget_1648657570650": { "value": da[:enter_school] },
                        "_widget_1648657570631": { "value": da[:leave_school] }, "_widget_1648657570612": { "value": da[:student_status] },
                        "_widget_1648657570593": { "value": da[:at_school] }, "_widget_1648657570574": { "value": da[:college] },
                        "_widget_1648657570555": { "value": da[:major] }, "_widget_1648657570536": { "value": da[:current_grade] },
                        "_widget_1648657570517": { "value": da[:classes] }, "_widget_1648657570498": { "value": da[:instructor_name] },
                        "_widget_1648657570479": { "value": da[:instructor_id] }, "_widget_1648657570460": { "value": da[:instructor_mobile] },
                        "_widget_1648657570441": { "value": da[:campus] }, "_widget_1648657570422": { "value": da[:dormitory] },
                        "_widget_1648657570384": { "value": da[:room] }, "_widget_1648657570403": { "value": da[:bed] } 
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
            # puts update_data.first
            update_data.each do |da|
                data = { 
                    "data_id": mapping[da[:userid].to_sym],
                    "data": {
                        "_widget_1648657570897": { "value": da[:userid] }, "_widget_1648657570878": { "value": da[:name] },
                        "_widget_1648657570859": { "value": da[:gender] }, "_widget_1648657570840": { "value": da[:birthday] },
                        "_widget_1648657570821": { "value": da[:nation] }, "_widget_1648657570802": { "value": da[:id_number] },
                        "_widget_1648657570783": { "value": da[:political] }, "_widget_1648657570764": { "value": da[:bank_card] },
                        "_widget_1648657570745": { "value": da[:mobile] }, "_widget_1648657570726": { "value": da[:email] },
                        "_widget_1648657570707": { "value": da[:education_system] }, "_widget_1648657570688": { "value": da[:student_category] },
                        "_widget_1648657570669": { "value": da[:cultivation_level] }, "_widget_1648657570650": { "value": da[:enter_school] },
                        "_widget_1648657570631": { "value": da[:leave_school] }, "_widget_1648657570612": { "value": da[:student_status] },
                        "_widget_1648657570593": { "value": da[:at_school] }, "_widget_1648657570574": { "value": da[:college] },
                        "_widget_1648657570555": { "value": da[:major] }, "_widget_1648657570536": { "value": da[:current_grade] },
                        "_widget_1648657570517": { "value": da[:classes] }, "_widget_1648657570498": { "value": da[:instructor_name] },
                        "_widget_1648657570479": { "value": da[:instructor_id] }, "_widget_1648657570460": { "value": da[:instructor_mobile] },
                        "_widget_1648657570441": { "value": da[:campus] }, "_widget_1648657570422": { "value": da[:dormitory] },
                        "_widget_1648657570384": { "value": da[:room] }, "_widget_1648657570403": { "value": da[:bed] }
                    }
                }
                jdy_post(data_update_url, data)
            end
        end
        # 删除简道云用户
        def self.jdy_data_delete(data_delete_url, delete_data, mapping)
            Rails.logger.info("delete #{delete_data.size}")
            # puts delete_data.first
            delete_data.each do |da|
                data = { 
                    "data_id": mapping[da[:userid].to_sym],
                    "data": {
                        "_widget_1648657570897": { "value": da[:userid] }, "_widget_1648657570878": { "value": da[:name] },
                        "_widget_1648657570859": { "value": da[:gender] }, "_widget_1648657570840": { "value": da[:birthday] },
                        "_widget_1648657570821": { "value": da[:nation] }, "_widget_1648657570802": { "value": da[:id_number] },
                        "_widget_1648657570783": { "value": da[:political] }, "_widget_1648657570764": { "value": da[:bank_card] },
                        "_widget_1648657570745": { "value": da[:mobile] }, "_widget_1648657570726": { "value": da[:email] },
                        "_widget_1648657570707": { "value": da[:education_system] }, "_widget_1648657570688": { "value": da[:student_category] },
                        "_widget_1648657570669": { "value": da[:cultivation_level] }, "_widget_1648657570650": { "value": da[:enter_school] },
                        "_widget_1648657570631": { "value": da[:leave_school] }, "_widget_1648657570612": { "value": da[:student_status] },
                        "_widget_1648657570593": { "value": da[:at_school] }, "_widget_1648657570574": { "value": da[:college] },
                        "_widget_1648657570555": { "value": da[:major] }, "_widget_1648657570536": { "value": da[:current_grade] },
                        "_widget_1648657570517": { "value": da[:classes] }, "_widget_1648657570498": { "value": da[:instructor_name] },
                        "_widget_1648657570479": { "value": da[:instructor_id] }, "_widget_1648657570460": { "value": da[:instructor_mobile] },
                        "_widget_1648657570441": { "value": da[:campus] }, "_widget_1648657570422": { "value": da[:dormitory] },
                        "_widget_1648657570384": { "value": da[:room] }, "_widget_1648657570403": { "value": da[:bed] }
                    }
                }
                jdy_post(data_delete_url, data)
            end
        end
end
