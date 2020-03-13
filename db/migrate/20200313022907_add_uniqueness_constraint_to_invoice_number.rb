class AddUniquenessConstraintToInvoiceNumber < ActiveRecord::Migration[6.0]
  def change
    remove_index :invoice_headers, :number
    add_index :invoice_headers, :number, unique: true
  end
end
