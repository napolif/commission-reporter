class AddLocationToCustomers < ActiveRecord::Migration[6.0]
  def change
    add_column :customers, :location, :integer, null: false

    remove_index :customers, name: "index_customers_on_code"
    add_index :customers, [:code, :location], unique: true
  end
end
