class AddAlphaCodeToSalesReps < ActiveRecord::Migration[6.0]
  def change
    add_column :sales_reps, :alpha_code, :string
  end
end
