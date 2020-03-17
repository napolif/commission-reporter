class RenameInvoicesToInvoiceSummaries < ActiveRecord::Migration[6.0]
  def change
    rename_table :invoices, :invoice_summaries
  end
end
