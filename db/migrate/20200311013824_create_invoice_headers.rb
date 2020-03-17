class CreateInvoiceHeaders < ActiveRecord::Migration[6.0]
  def change
    create_table :invoice_headers do |t|
      t.string :number
      t.string :rep_code
      t.string :customer_code
      t.decimal :amount, precision: 10, scale: 2
      t.decimal :cost, precision: 10, scale: 2
      t.date :order_date
      t.integer :qty_ord

      t.timestamps
    end
    add_index :invoice_headers, :number
    add_index :invoice_headers, :rep_code
    add_index :invoice_headers, :customer_code
  end
end
