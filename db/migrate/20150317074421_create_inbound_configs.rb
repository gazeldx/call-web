class CreateInboundConfigs < ActiveRecord::Migration
  def change
    create_table :inbound_configs do |t|
      t.belongs_to  :company, index: true
      t.integer :inbound_number_id   # 呼入号码
      t.integer :config_type         # 配置类型 0-转ivr; 1-转企业彩铃; 2-转企业总机; 3-转号码策略
      t.string :strategy_ids         # 策略id集合
      t.integer :ivr_id              # ivr/企业彩铃/企业总机

      #t.timestamps
    end

    # add_column :inbound_configs, :max_inbound, :integer # 最大呼入数量
  end
end
