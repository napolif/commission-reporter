class RenamePaidInvoicesToInvoices < ActiveRecord::Migration[6.0]
  def change
    rename_table :paid_invoices, :invoices
  end
end
