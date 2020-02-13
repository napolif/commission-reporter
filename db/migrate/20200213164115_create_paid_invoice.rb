class CreatePaidInvoice < ActiveRecord::Migration[6.0]
  def change
    create_table :paid_invoices do |t|
      t.string :batch, index: true
      t.string :number
      t.string :sales_rep_code, index: true
      t.date :invoiced_on
      t.date :paid_on
      t.decimal :amount, precision: 8, scale: 2
      t.decimal :cost, precision: 8, scale: 2
      t.string :customer_id
      t.string :customer_name
      t.integer :cases
      t.boolean :delivered

      t.timestamps
    end

    add_index :paid_invoices, [:batch, :sales_rep_code]
  end
end
