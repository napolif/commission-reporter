ActiveAdmin.register Customer do
  menu priority: 2

  permit_params :code, :name

  filter :code
  filter :name

  index do
    id_column
    selectable_column
    column :code
    column :name
    actions
  end
end
