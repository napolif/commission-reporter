ActiveAdmin.register InvoiceHeader do
  menu priority: 2

  permit_params :amount, :cost, :customer_code, :number, :order_date, :qty_ord, :rep_code

  filter :number
  filter :rep_code
  filter :order_date

  index do
    selectable_column
    column :number
    column :amount
    column :cost
    column :customer_code
    column :order_date
    column :qty_ord
    column :rep_code
    actions
  end
end
