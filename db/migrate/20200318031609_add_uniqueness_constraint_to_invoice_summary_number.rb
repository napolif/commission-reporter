class AddUniquenessConstraintToInvoiceSummaryNumber < ActiveRecord::Migration[6.0]
  def change
    remove_index :invoice_summaries, :number
    add_index :invoice_summaries, :number, unique: true
  end
end
