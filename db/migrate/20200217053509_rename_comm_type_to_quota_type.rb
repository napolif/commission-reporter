class RenameCommTypeToQuotaType < ActiveRecord::Migration[6.0]
  def change
    rename_column :sales_reps, :comm_type, :quota_type
  end
end
