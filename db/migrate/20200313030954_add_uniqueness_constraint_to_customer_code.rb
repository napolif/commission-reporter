class AddUniquenessConstraintToCustomerCode < ActiveRecord::Migration[6.0]
  def change
    remove_index :customers, :code
    add_index :customers, :code, unique: true
  end
end
