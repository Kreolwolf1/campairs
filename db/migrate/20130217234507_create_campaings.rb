class CreateCampaings < ActiveRecord::Migration
  def change
    create_table :campaings do |t|
      t.string :name
      t.json :countries

      t.timestamps
    end

    add_start_at_column_sql = 'ALTER TABLE campaings ADD COLUMN start_at timestamp with time zone;'
    add_end_at_column_sql = 'ALTER TABLE campaings ADD COLUMN end_at timestamp with time zone;'

  	ActiveRecord::Base.connection.execute(add_start_at_column_sql)
  	ActiveRecord::Base.connection.execute(add_end_at_column_sql)
  end

  def down
  	drop_table :campaings
  end
end
