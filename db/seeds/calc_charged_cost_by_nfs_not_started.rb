# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:calc_charged_cost_by_nfs_not_started`
reports = Cdr.where(start_stamp: (DateTime.parse("2015-11-28 00:00:01"))..(DateTime.parse("2015-11-28 09:43:30"))).where('cost > 0').select("company_id, sum(cost) as cost").group('company_id')

reports.sort_by { |report| report.cost }.reverse!.each_with_index do |report, i|
  puts "#{i + 1} #{report.company_id} 补: #{report.cost}" if report.cost > 0
end