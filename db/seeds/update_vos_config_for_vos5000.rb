# 批量更新企业的VOS IPs。
# You can run this seed by `$ rake db:seed:update_vos_config_for_vos5000 start_company_id=60497 end_company_id=60497`
new_vos_id = 22
new_ip = "172.31.1.102"
Company.where(id: (ENV['start_company_id']..ENV['end_company_id']).to_a).order(:id).each_with_index do |company, i|
  old_trunk = $redis.hgetall("acdqueue:trunk:#{company.id}")
  if (company.manual_call_vos_id != new_vos_id || company.task_vos_id != new_vos_id) && old_trunk.present?
    puts "#{i} #{company.id} - before pg: { manual_call_vos_id: #{company.manual_call_vos_id}, task_vos_id: #{company.task_vos_id} }, redis: {#{"#{old_trunk['manualcall_trunk_ip']}, #{old_trunk['task_trunk_ip']}" if old_trunk.present?}} #{old_trunk.inspect}"

    company.update!(manual_call_vos_id: new_vos_id, task_vos_id: new_vos_id)
    $redis.mapped_hmset("acdqueue:trunk:#{company.id}", { manualcall_trunk_ip: new_ip, task_trunk_ip: new_ip })

    new_trunk = $redis.hgetall("acdqueue:trunk:#{company.id}")
    puts "#{i} #{company.id} - after  pg: { manual_call_vos_id: #{company.manual_call_vos_id}, task_vos_id: #{company.task_vos_id} }, redis: {#{"#{new_trunk['manualcall_trunk_ip']}, #{new_trunk['task_trunk_ip']}" if new_trunk.present?}} #{new_trunk.inspect}"
  end
end