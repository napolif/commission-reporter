class AddUniquenessConstraintToSalesRepCode < ActiveRecord::Migration[6.0]
  def change
    add_index :sales_reps, :code, unique: true
  end
end
