# ActiveAdmin.register InvoiceSummary do
#   menu priority: 2
#
#   permit_params :batch, :number, :sales_rep_code, :invoiced_on, :paid_on, :amount, :cost,
#                 :customer_code, :customer_name, :cases, :delivered
#
#   filter :sales_rep_code
#   filter :delivered
#   filter :batch
#
#   index do
#     selectable_column
#     column :number
#     column :batch
#     column :sales_rep_code
#     column :invoiced_on
#     column :paid_on
#     column :amount
#     column :cost
#     column :customer_code
#     column :cases
#     column :delivered
#     actions
#   end
# end
