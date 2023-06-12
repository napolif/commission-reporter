class AddCreatedDateToInvoiceHeaders < ActiveRecord::Migration[6.0]
  def change
    add_column :invoice_headers, :created_date, :date
    add_index :invoice_headers, :created_date
  end
end
