class ChangeIdAsStringInCdrs < ActiveRecord::Migration
  def up
    change_table :cdrs do |t|
      t.change :id, :string
    end

    change_column_default(:cdrs, :id, nil)

    change_table :contacts do |t|
      t.change :cdr_id, :string
    end
  end

  def down
    # change_column :cdrs, :id, 'integer USING CAST(id AS integer)'
    #
    # change_column :contacts, :cdr_id, 'integer USING CAST(cdr_id AS integer)'
  end
end
