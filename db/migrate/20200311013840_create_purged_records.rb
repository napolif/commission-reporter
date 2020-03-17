class CreatePurgedRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :purged_records do |t|
      t.string :number
      t.decimal :amount, precision: 10, scale: 2
      t.string :customer_code
      t.string :rep_code
      t.date :due_date
      t.date :created_date
      t.string :adj_code
      t.string :ref_number

      t.timestamps
    end
    add_index :purged_records, :number
    add_index :purged_records, :rep_code
    add_index :purged_records, :adj_code
  end
end
