class RedisHelp
  class << self
    def add_agent(company_id, agent_code, show_number, charge_agent)
      sipno = "#{company_id}#{agent_code}"

      $redis.mapped_hmset("acdqueue:agent:#{sipno}",
                          { id: sipno,
                            status: 'Ready', # status和state的含义见：views/agents_monitor/index.html.slim
                            state: 'Waiting',
                            type: 'callback',
                            ready_time: 0,
                            contact_type: 'Sip',
                            contact: sipno,
                            last_offered_call: 0,
                            last_bridge_end: 0,
                            uuid: nil,
                            system: 'fs1',
                            serving_member: nil,
                            tenant_id: company_id,
                            show_number: show_number,
                            is_sign: 0,
                            callback_show_type: 1,
                            default_callback_number: nil
                          })

      #座席和绑定号码对应关系
      $redis.set("acdqueue:agent:contact_number:#{sipno}", sipno)

      $redis.set("OUT:#{sipno}", 'Available')

      # Rails::logger.info " ----------------- charge_agent is #{charge_agent.inspect} ----------"
      $redis.mapped_hmset("charge:agent:#{sipno}",
                          { charge_id: charge_agent[:charge_id],
                            min_fee_balance: charge_agent[:min_fee_balance],
                            minutes: charge_agent[:minutes],
                            monthly_rent: charge_agent[:monthly_rent]
                          })
      
      if ChargeAgent.get_class_name_by_charge_id(charge_agent[:charge_id]) == ChargeAgentShareMinfee
        update_share_fee(company_id, ChargeAgent.charge_fee(charge_agent[:charge_id], company_id))
      end
    end

    def delete_agent(agent)
      agent.extensions.each do |extension|
        del_extension(extension)
      end

      $redis.set("OUT:#{agent.id}", 'NotAvailable')

      $redis.del("charge:agent:#{agent.id}")

      $redis.smembers("acdqueue:tier:#{agent.id}").each do |group_id|
        group_rm_agents(Group.find(group_id), [agent])
      end

      $redis.del("acdqueue:tier:#{agent.id}")

      $redis.del("acdqueue:agent:contact_number:#{agent.contact_number}")

      $redis.del("acdqueue:agent:#{agent.id}")

      del_agent_salesman_id(agent.id)
    end

    def agent_can_be_destroy?(agent)
      redis_agent = $redis.hmget("acdqueue:agent:#{agent.id}", 'status', 'state', 'last_bridge_end')

      if ['Logged_Out', 'Ready'].include?(redis_agent.first) and redis_agent.second == 'Waiting'
        true
      else
        Time.now.to_i - redis_agent.third.to_i > 3600 * 2 # 座席2个小时内没有通话，可以被直接禁用
      end
    end

    def update_agent_show_number(sipno, show_number)
      $redis.mapped_hmset("acdqueue:agent:#{sipno}", { show_number: show_number })
    end

    def update_agent_contact(agent, original_contact_number)
      $redis.mapped_hmset("acdqueue:agent:#{agent.id}", { contact_type: agent.transfer? ? 'Hard' : 'Sip',
                                                          contact: agent.contact_number })

      $redis.del("acdqueue:agent:contact_number:#{original_contact_number}")
      $redis.set("acdqueue:agent:contact_number:#{agent.contact_number}", agent.id)
    end

    def del_caller_numbers
      caller_numbers = $redis.keys("acdqueue:tenant_number:caller_number:*")

      $redis.del(caller_numbers) unless caller_numbers.blank?
    end

    def del_company_caller_numbers(company_id)
      caller_numbers = $redis.keys("acdqueue:tenant_number:caller_number:#{company_id}:*")

      $redis.del(caller_numbers) unless caller_numbers.blank?
    end

    def set_caller_number(company_id, caller_number, expire_at)
      expire_time = (Time.parse(expire_at) + 8.hours).strftime("%Y-%m-%d %H:%M:%S")

      $redis.set("acdqueue:tenant_number:caller_number:#{company_id}:#{caller_number}", expire_time)
    end

    def del_caller_number(company_id, caller_number)
      $redis.del("acdqueue:tenant_number:caller_number:#{company_id}:#{caller_number}")
    end

    def get_agent_out(agent_id)
      $redis.get("OUT:#{agent_id}")
    end

    # 创建座席组并添加成员
    def add_group(group)
      set_group(group)

      group_add_agents(group, group.agents)
    end

    def update_group(group, rm_agents, add_agents)
      set_group(group)

      # 移除的座席处理
      group_rm_agents(group, rm_agents)

      # 新增加的座席处理
      group_add_agents(group, add_agents)
    end

    def remove_group(group)
      update_group(group, group.agents, [])

      $redis.del("acdqueue:queue:#{group.id}")
    end

    def update_charge_agent(charge_agent)
      $redis.mapped_hmset("charge:agent:#{charge_agent.agent_id}",
                          { charge_id: charge_agent.charge_id,
                            min_fee_balance: charge_agent.min_fee_balance,
                            minutes: charge_agent.minutes,
                            monthly_rent: charge_agent.monthly_rent
                          })
    end

    def update_share_fee(company_id, agent_min_fee)
      $redis.set("charge:share:fee:#{company_id}", $redis.get("charge:share:fee:#{company_id}").to_f + agent_min_fee)
    end

    # 当座席因为误开套餐而需要禁用时, 需要扣除共享保底。
    # 座席被禁用往往是因为技术误开了座席, 企业会要求补款, 所以就有了本method。
    # 目前禁用的逻辑中并没有区分是技术误开了座席还是企业要求禁用, 所以技术或客服需要禁用共享保底的座席时, 最好是点击“月底禁用”，而不是直接“禁用”。
    def deduct_share_fee_when_disable_agent(company_id, agent_min_fee)
      $redis.set("charge:share:fee:#{company_id}", $redis.get("charge:share:fee:#{company_id}").to_f - agent_min_fee)
    end

    # 设置座席的呼入接听优先级
    def set_agent_inbound_level(agent_id, group_id, new_level, old_level)
      $redis.lrem(   "acdqueue:agentqueue:#{level_as_word(old_level)}:#{group_id}", 0, agent_id)
      $redis.lrem("acdqueue:agentqueuebak:#{level_as_word(old_level)}:#{group_id}", 0, agent_id)

      $redis.rpush(   "acdqueue:agentqueue:#{level_as_word(new_level)}:#{group_id}", agent_id)
      $redis.rpush("acdqueue:agentqueuebak:#{level_as_word(new_level)}:#{group_id}", agent_id)

      # 设置座席呼入在呼入组中的优先级
      $redis.set("acdqueue:tier:#{group_id}:#{agent_id}:level", level_as_word(new_level))
    end

    # 添加语音文件
    def add_voice(voice)
      $redis.set("acdqueue:voice:#{voice.id}", voice.file)
    end

    def del_voice(voice_id)
      $redis.del("acdqueue:voice:#{voice_id}")
    end

    def set_company_voses(voses_hash)
      $redis.mapped_hmset("acdqueue:trunk:#{voses_hash[:company_id]}",
                          { manualcall_trunk_ip: voses_hash[:manualcall_trunk_ip],
                            manualcall_trunk_port: voses_hash[:manualcall_trunk_port],
                            manualcall_prefix: voses_hash[:manualcall_prefix],
                            callback_trunk_ip: voses_hash[:callback_trunk_ip],
                            callback_trunk_port: voses_hash[:callback_trunk_port],
                            callback_prefix: voses_hash[:callback_prefix],
                            task_trunk_ip: voses_hash[:task_trunk_ip],
                            task_trunk_port: voses_hash[:task_trunk_port],
                            task_prefix: voses_hash[:task_prefix] })
    end

    # Notice: 目前本方法还没有被使用过。
    def del_company_vos_configs(company_id)
      $redis.del("acdqueue:trunk:#{company_id}")
    end

    # 语音营销按键转接任务IVR 写入 redis
    # queue_name： 转接的座席组   dtmf: 按键值
    def add_keypress_transfer_ivr(ivr_id, queue_name, dtmf, voice_id)
      node_id = ivr_id.to_s + '_1'
      action_id = ivr_id.to_s + '_1_1'
      #ivr
      $redis.mapped_hmset("acdqueue:ivr:#{ivr_id}", { name: '语音营销按键转接任务IVR', root_node: node_id })
      #ivr_node
      $redis.mapped_hmset("acdqueue:ivr_node:#{node_id}",
                          { id: node_id,
                            father_node: '',
                            text: '根节点',
                            timeout: '',
                            action: '',
                            value: '',
                            voice_id: voice_id,
                            repeat: 1 })
      #ivr_node_action
      $redis.set("acdqueue:ivr_node:#{node_id}:#{dtmf}",action_id)
      $redis.mapped_hmset("acdqueue:ivr_node_action:#{action_id}",
                          { id: action_id,
                            action: 'Trans_Group',
                            value: queue_name })
    end

    # 语音营销按键采集任务IVR 写入 redis
    def add_keypress_gather_ivr(ivr_id, dtmf, voice_id)
      node_id = ivr_id.to_s + '_1'
      action_id = ivr_id.to_s + '_1_1'
      #ivr
      $redis.mapped_hmset("acdqueue:ivr:#{ivr_id}", { name: '语音营销按键采集任务IVR', root_node: node_id })
      #ivr_node
      $redis.mapped_hmset("acdqueue:ivr_node:#{node_id}",
                          { id:  node_id,
                            father_node: '',
                            text: '根节点',
                            timeout: '',
                            action: '',
                            value: '',
                            voice_id: voice_id,
                            repeat: 1 })
      #ivr_node_action
      $redis.set("acdqueue:ivr_node:#{node_id}:#{dtmf}",action_id)
      $redis.mapped_hmset("acdqueue:ivr_node_action:#{action_id}",
                          { id:  action_id,
                            action: 'Hangup',
                            value: -1 })
    end

    def set_group(group)
      $redis.mapped_hmset("acdqueue:queue:#{group.id}", group_hash(group))
    end

    def group_add_agents(group, agents)
      agents.each do |agent|
        if group.outbound?
          $redis.rpush(   "acdqueue:agentqueue:#{group.id}", agent.id)
          $redis.rpush("acdqueue:agentqueuebak:#{group.id}", agent.id)
        else
          $redis.rpush(   "acdqueue:agentqueue:medium:#{group.id}", agent.id)
          $redis.rpush("acdqueue:agentqueuebak:medium:#{group.id}", agent.id)
        end

        # 座席队列集合
        $redis.sadd("acdqueue:tier:#{agent.id}", group.id)

        # 队列座席状态
        $redis.set(tier_group_agent_state(group, agent), tier_state(agent))

        unless group.outbound?
          # 设置座席呼入在呼入组中的优先级
          $redis.set("acdqueue:tier:#{group.id}:#{agent.id}:level", 'medium')
        end
      end
    end

    def busy_agents(group, agents)
      agents.each { |agent| return [agent] if busying?(group, agent) }
      []
    end

    # 判断是否是“Offering: 正在发起呼叫”或“Active_Inbound: 正在通话中”，呼入或者任务外呼时才会出现
    def busying?(group, agent)
      state = $redis.get(tier_group_agent_state(group, agent))

      state.present? && state != 'Ready'
    end

    def group_rm_agents(group, agents)
      agents.each do |agent|
        # 这一段代码可能导致下面的redis数据无法删除, 只在系统出故障并且座席没有被禁用时、且发生了企业下线(company.vacuum)时, 才出现。史已经确认, 没问题。
        unless busying?(group, agent) # 其实本判断也可以不加，因为外层我还做了相关判断了，加了双保险
          if group.outbound?
            $redis.lrem(   "acdqueue:agentqueue:#{group.id}", 0, agent.id)
            $redis.lrem("acdqueue:agentqueuebak:#{group.id}", 0, agent.id)
          else
            ['high', 'medium', 'low'].each do |level|
              $redis.lrem(   "acdqueue:agentqueue:#{level}:#{group.id}", 0, agent.id)
              $redis.lrem("acdqueue:agentqueuebak:#{level}:#{group.id}", 0, agent.id)
            end

            $redis.del("acdqueue:tier:#{group.id}:#{agent.id}:level")
          end

          # 删除座席队列集合
          $redis.srem("acdqueue:tier:#{agent.id}", group.id)

          # 删除队列座席状态
          $redis.del(tier_group_agent_state(group, agent))
        end
      end
    end

    def add_inbound_number(inbound_config)
      is_strategy, strategy_id = 0, ""
      ivr_id = inbound_config.ivr_id
      if inbound_config.config_type == 3
        type, is_strategy = "Strategy", 1
        strategy_id = inbound_config.ivr_id
      else
        name = ["Trans_Ivr","Trans_Coloring","Trans_Exchange",""]
        type = name[inbound_config.config_type] || "Trans_Ivr"
      end
      $redis.mapped_hmset("acdqueue:tenant_number:inbound_number:#{inbound_config.inbound_number}",
                          { number: inbound_config.inbound_number,
                            tenant_id: inbound_config.company_id,
                            ivr: ivr_id,
                            is_strategy: is_strategy,
                            strategy_id: strategy_id,
                            type: type,
                            max_inbound: inbound_config.max_inbound,
                            has_vip: inbound_config.has_vip,
                            has_rate: inbound_config.has_rate,
                            rate_id: inbound_config.rate_id})
    end

    def del_inbound_number(inbound_number)
      $redis.del("acdqueue:tenant_number:inbound_number:#{inbound_number}")
    end

    # action_id  #转ivr,转总机，转彩铃，挂断
    # local_strategy # 地区
    # time_strategy  # 时间
    def add_strategy(strategy)
      action_id = "strategy_#{strategy.id}"
      local_strategy = strategy.local.blank? ? "" : "1|#{strategy.local}"
      time_strategy ="#{strategy.allow_date}&#{strategy.not_allow_date}&#{strategy.week}&#{strategy.time}"
      add_action(action_id, strategy.action, strategy.value)
      $redis.mapped_hmset("acdqueue:strategy_action:#{strategy.id}",
                          { id: strategy.id,
                            action_id: action_id,
                            local_strategy: local_strategy,
                            time_strategy: time_strategy })
    end

    def del_strategy(strategy_id)
      $redis.del("acdqueue:strategy_action:#{strategy_id}")
      action_id = "strategy_#{strategy_id}"
      del_action(action_id)
    end

    def add_strategy_list(group_id, strategy_ids)
      $redis.set("acdqueue:strategy_list:#{group_id}", strategy_ids)
    end

    def del_strategy_list(group_id)
      $redis.del("acdqueue:strategy_list:#{group_id}")
    end

    def add_ivr(ivr)
      $redis.mapped_hmset("acdqueue:ivr:#{ivr.id}", { name: 'ivr_name', root_node: ivr.node_id })
    end

    def del_ivr(ivr_id)
      $redis.del("acdqueue:ivr:#{ivr_id}")
    end

    def add_color_ring(color_ring)
     # acdqueue:coloring:[id]   tenant_id  group_id   voice_id    min_sec-最少播放时长，单位秒
      $redis.mapped_hmset("acdqueue:coloring:#{color_ring.id}",
                          { tenant_id: color_ring.company_id,
                            group_id: color_ring.node_id,
                            voice_id: color_ring.timeout_value,
                            min_sec: color_ring.timeout_length})
    end

    def del_color_ring(color_ring_id)
      $redis.del("acdqueue:coloring:#{color_ring_id}")
    end

    def add_ivr_node(node, timeout, timeout_repeat, timeout_action, timeout_value, ivr_type)
      case node.action
      when "Voice" then
        max_digits, min_digits = 1, 1
        max = $redis.hmget("acdqueue:ivr_node:#{node.id}", 'max_digits').first
        min = $redis.hmget("acdqueue:ivr_node:#{node.id}", 'min_digits').first
        max_digits = max.to_i unless max.blank?
        min_digits = min.to_i unless min.blank?

        add_action(node.id, timeout_action, timeout_value)

        $redis.mapped_hmset("acdqueue:ivr_node:#{node.id}",
                             { id: node.id,
                               max_digits: max_digits,
                               min_digits: min_digits,
                               timeout: timeout,
                               action: node.id,
                               voice_id: node.value,
                               repeat: timeout_repeat,
                               tries: 1 })

        digit_info(node.parent_id, node.from_digits, "Trans_Node", node.id) unless node.root_node?
      when "Parent_Node" then
        digit_info(node.parent_id, node.from_digits, "Trans_Node", node.value)
      else
       # node_id =  ivr_type == 4 ? node.patriline : node.parent_id
        digit_info(node.parent_id, node.from_digits, node.action, node.value)
      end
    end

    def digit_info(node_id, digit, action, value)
      set_digits(node_id, digit.length)
      add_digit(node_id, digit, action, value)
    end

    def del_ivr_node(node)
      if node.root_node?
        $redis.del("acdqueue:ivr_node:#{node.id}")
      else
        action_id = $redis.get("acdqueue:ivr_node:#{node.parent_id}:#{node.from_digits}")
        del_action(action_id)
        del_digit(node.parent_id,node.from_digits)
      end
    end

    def add_digit(node_id, dtmf, action, value)
      action_id = "#{node_id}_#{dtmf}"
      $redis.set("acdqueue:ivr_node:#{node_id}:#{dtmf}",action_id)
      add_action(action_id, action, value)
    end

    def del_digit(node_id, dtmf)
      $redis.del("acdqueue:ivr_node:#{node_id}:#{dtmf}")
    end

    def set_digits(node_id, digit_length)
      if $redis.hmget("acdqueue:ivr_node:#{node_id}", 'max_digits').first.to_i < digit_length
        $redis.mapped_hmset( "acdqueue:ivr_node:#{node_id}", { max_digits: digit_length } )
      end
      if $redis.hmget("acdqueue:ivr_node:#{node_id}", 'min_digits').first.to_i > digit_length
        $redis.mapped_hmset( "acdqueue:ivr_node:#{node_id}", { min_digits: digit_length } )
      end
    end

    def add_action(action_id, action, value)
      $redis.mapped_hmset("acdqueue:ivr_node_action:#{action_id}", { id: action_id, action: action, value: value })
    end

    def del_action(action_id)
      $redis.del("acdqueue:ivr_node_action:#{action_id}")
    end

    def add_extension(extension_config)
      object_id = extension_config.group_id if extension_config.extension_type == 0
      object_id = extension_config.agent_id if extension_config.extension_type == 1
      $redis.mapped_hmset("acdqueue:extension:#{extension_config.company_id}:#{extension_config.extension}",
                          { type: extension_config.extension_type,
                            object_id: object_id })
    end

    def del_extension(extension_config)
      $redis.del("acdqueue:extension:#{extension_config.company_id}:#{extension_config.extension}")
    end

    def add_vip(vip)
      action_id = "vip_#{vip.id}"
      action_name = ["Trans_Ivr","Trans_Coloring","Trans_Exchange","Strategy"]
      action = action_name[vip.action.to_i] || "Trans_Ivr"
      add_action(action_id, action, vip.value)
      $redis.set("acdqueue:vip:#{vip.id}", action_id)
    end

    def del_vip(vip_id)
      del_action("vip_#{vip_id}")
      $redis.del("acdqueue:vip:#{vip_id}")
    end

    def set_customer_vip(customer)
      if customer.vip_id.nil?
        $redis.del("acdqueue:vip:#{customer.company_id}:#{customer.s1}")
      else
        $redis.set("acdqueue:vip:#{customer.company_id}:#{customer.s1}", customer.vip_id)
      end
    end

    def set_inbound_number_max_lines(inbound_number, max_lines)
      $redis.mapped_hmset("acdqueue:tenant_number:inbound_number:#{inbound_number}", { max_inbound: max_lines })
    end

    def initialize_inbound_company(company_id)
      $redis.set("IN:#{company_id}", 'Available')
    end

    def del_inbound_company(company_id)
      $redis.del("IN:#{company_id}")
    end

    def update_as_available(company)
      $redis.set("IN:#{company.id}", 'Available') if $redis.get("IN:#{company.id}") == 'NotAvailable'

      company.agents.each_with_index do |agent|
        $redis.set("OUT:#{agent.id}", 'Available') if $redis.get("OUT:#{agent.id}") == 'NotAvailable'
      end
    end

    def handle_share_minfee(company)
      if $redis.get("charge:share:frozen:#{company.id}").to_f > 0
        $redis.set("charge:share:fee:#{company.id}", $redis.get("charge:share:fee:#{company.id}").to_f + $redis.get("charge:share:frozen:#{company.id}").to_f)
        $redis.del("charge:share:frozen:#{company.id}")
      end
    end

    def increase_package_records_times(company_id)
      company_package_records = $redis.hgetall("ucweb:package_records:#{company_id}")
      if company_package_records.present? && company_package_records['date'] == Time.now.strftime(I18n.t(:date_digits))
        $redis.mapped_hmset("ucweb:package_records:#{company_id}", { times: company_package_records['times'].to_i + 1 })
      else
        $redis.mapped_hmset("ucweb:package_records:#{company_id}", { times: 1, date: Time.now.strftime(I18n.t(:date_digits)) })
      end
    end

    def package_records_times(company_id)
      company_package_records = $redis.hgetall("ucweb:package_records:#{company_id}")
      if company_package_records.present? && company_package_records['date'] == Time.now.strftime(I18n.t(:date_digits))
        return company_package_records['times'].to_i
      else
        return 0
      end
    end

    def increase_batch_mixin_record_times(company_id)
      company_batch_mixin_record = $redis.hgetall("ucweb:batch_mixin_record:#{company_id}")
      if company_batch_mixin_record.present? && company_batch_mixin_record['date'] == Time.now.strftime(I18n.t(:date_digits))
        $redis.mapped_hmset("ucweb:batch_mixin_record:#{company_id}", { times: company_batch_mixin_record['times'].to_i + 1 })
      else
        $redis.mapped_hmset("ucweb:batch_mixin_record:#{company_id}", { times: 1, date: Time.now.strftime(I18n.t(:date_digits)) })
      end
    end

    def batch_mixin_record_times(company_id)
      company_batch_mixin_record = $redis.hgetall("ucweb:batch_mixin_record:#{company_id}")
      if company_batch_mixin_record.present? && company_batch_mixin_record['date'] == Time.now.strftime(I18n.t(:date_digits))
        return company_batch_mixin_record['times'].to_i
      else
        return 0
      end
    end

    def agents_today_report(company_id)
      $redis.hgetall("ucweb:agents_today_report:#{company_id}")
    end

    def update_query_at_of_agents_today_report(company_id)
      $redis.mapped_hmset("ucweb:agents_today_report:#{company_id}", { query_at: Time.now.to_i })
    end

    # 在处理话单时要查座席的销售员id. 对数据库的性能产生有影响。所以通过记入Redis提升性能。
    def set_agent_salesman_id(agent_id, salesman_id)
      if salesman_id.present?
        $redis.set("ucweb:agent:#{agent_id}:salesman_id", salesman_id)
      else
        del_agent_salesman_id(agent_id)
      end
    end

    def del_agent_salesman_id(agent_id)
      $redis.del("ucweb:agent:#{agent_id}:salesman_id")
    end

    private

    def group_hash(group)
      puts "group.max_wait_time: #{group.max_wait_time}"
      result = { name: group.id,
                 strategy: 'sequence',
                 moh: "local_stream://moh",
                 max_wait_time: Group::DEFAULT_MAX_WAIT_TIME,
                 type: (group.outbound? ? 'campaign' : 'inbound') }

      unless group.outbound?
        result.merge!({ is_spill: boolean_to_integer(group.spill?),
                        spill_count: group.spill_count,
                        is_play_spill_voice: boolean_to_integer(group.play_spill_voice?),
                        spill_ivr: group.spill_ivr_id,

                        is_timeout: boolean_to_integer(group.timeout?),
                        max_wait_time: group.max_wait_time || Group::DEFAULT_MAX_WAIT_TIME,
                        is_play_timeout_voice: boolean_to_integer(group.play_timeout_voice?),
                        max_loop_times: (group.max_loop_times || Group::DEFAULT_MAX_LOOP_TIMES) + 1,
                        timeout_ivr: group.timeout_ivr_id
                      })
      end

      return result
    end

    def boolean_to_integer(boolean)
      boolean ? 1 : 0
    end

    def tier_group_agent_state(group, agent)
      "acdqueue:tier:#{group.id}:#{agent.id}:state"
    end

    def tier_state(agent)
      if $redis.hget("acdqueue:agent:#{agent.id}", 'state') == 'Waiting'
        'Ready'
      else
        'Standby'
      end
    end

    # TODO: 本方法已经移植到agents_groups.rb，可以重构清理掉
    def level_as_word(level)
      case level
        when AgentsGroups::LEVEL_LOW then 'low'
        when AgentsGroups::LEVEL_HIGH then 'high'
        else 'medium'
      end
    end
  end
end