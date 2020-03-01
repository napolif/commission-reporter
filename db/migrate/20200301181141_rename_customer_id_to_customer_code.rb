class RenameCustomerIdToCustomerCode < ActiveRecord::Migration[6.0]
  def change
    rename_column :invoices, :customer_id, :customer_code
  end
end
