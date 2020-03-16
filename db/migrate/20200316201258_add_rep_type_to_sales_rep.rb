class AddRepTypeToSalesRep < ActiveRecord::Migration[6.0]
  def change
    add_column :sales_reps, :rep_type, :string, null: false, default: "outside"
    add_index :sales_reps, :rep_type
  end
end
