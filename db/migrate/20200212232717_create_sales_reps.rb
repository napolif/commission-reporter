class CreateSalesReps < ActiveRecord::Migration[6.0]
  def change
    create_table :sales_reps do |t|
      t.string :code
      t.string :name
      t.string :comm_type

      t.decimal :period1, precision: 8, scale: 2
      t.decimal :period2, precision: 8, scale: 2
      t.decimal :period3, precision: 8, scale: 2
      t.decimal :period4, precision: 8, scale: 2
      t.decimal :period5, precision: 8, scale: 2

      t.decimal :goal1, precision: 8, scale: 2
      t.decimal :goal2, precision: 8, scale: 2
      t.decimal :goal3, precision: 8, scale: 2
      t.decimal :goal4, precision: 8, scale: 2
      t.decimal :goal5, precision: 8, scale: 2
      t.decimal :goal6, precision: 8, scale: 2
      t.decimal :goal7, precision: 8, scale: 2
      t.decimal :goal8, precision: 8, scale: 2
      t.decimal :goal9, precision: 8, scale: 2
      t.decimal :goal10, precision: 8, scale: 2

      t.decimal :comm1, precision: 8, scale: 2
      t.decimal :comm2, precision: 8, scale: 2
      t.decimal :comm3, precision: 8, scale: 2
      t.decimal :comm4, precision: 8, scale: 2
      t.decimal :comm5, precision: 8, scale: 2
      t.decimal :comm6, precision: 8, scale: 2
      t.decimal :comm7, precision: 8, scale: 2
      t.decimal :comm8, precision: 8, scale: 2
      t.decimal :comm9, precision: 8, scale: 2
      t.decimal :comm10, precision: 8, scale: 2

      t.timestamps
    end
  end
end
