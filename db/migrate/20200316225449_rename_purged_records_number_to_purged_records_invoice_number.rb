class RenamePurgedRecordsNumberToPurgedRecordsInvoiceNumber < ActiveRecord::Migration[6.0]
  def change
    rename_column :purged_records, :number, :invoice_number
  end
end
