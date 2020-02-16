class AddDisabledToSalesReps < ActiveRecord::Migration[6.0]
  def change
    add_column :sales_reps, :disabled, :boolean, null: false, default: false
    add_index :sales_reps, :disabled
  end
end
