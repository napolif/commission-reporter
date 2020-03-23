ActiveAdmin.register PurgedRecord do
  menu priority: 2

  permit_params :amount, :cost, :customer_code, :number, :order_date, :qty_ord, :rep_code

  filter :invoice_number
  filter :rep_code
  filter :invoice_type
  filter :adj_code

  index do
    selectable_column
    column :invoice_number
    column :customer_code
    column :amount
    column :created_date
    column :due_date
    column :invoice_type
    column :rep_code
    column :ref_number
    column :adj_code
    actions
  end
end
