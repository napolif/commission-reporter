class CreateCustomers < ActiveRecord::Migration[6.0]
  def change
    create_table :customers do |t|
      t.string :code
      t.string :name

      t.timestamps
    end
    add_index :customers, :code
  end
end
