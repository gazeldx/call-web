# 本文件不再使用了，只用于首套系统一次性的数据增补。
# You can run this seed by `$ rake db:seed:update_old_automatic_tasks_to_predict_tasks`
updated_count = Bundle.where(kind: Bundle::KIND_AUTOMATIC).update_all(kind: Bundle::KIND_PREDICT)
puts "共#{updated_count}个自动外呼任务被更新成预测外呼任务"