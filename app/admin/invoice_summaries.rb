ActiveAdmin.register InvoiceSummary do
  menu priority: 2

  permit_params :batch, :number, :sales_rep_code, :invoiced_on, :paid_on, :amount, :cost,
                :customer_code, :customer_name, :cases, :delivered
end
