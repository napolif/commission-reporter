class AddInvoiceTypeToPurgedRecords < ActiveRecord::Migration[6.0]
  def change
    add_column :purged_records, :invoice_type, :integer, null: false, default: 1
  end
end
