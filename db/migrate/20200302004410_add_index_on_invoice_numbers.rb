class AddIndexOnInvoiceNumbers < ActiveRecord::Migration[6.0]
  def change
    add_index :invoices, :number
  end
end
