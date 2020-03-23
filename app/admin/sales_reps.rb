ActiveAdmin.register SalesRep do
  menu priority: 2

  permit_params :code, :name, :quota_type, :disabled,
                :period1, :period2, :period3, :period4, :period5,
                :goal1, :goal2, :goal3, :goal4, :goal5, :goal6, :goal7, :goal8, :goal9, :goal10,
                :comm1, :comm2, :comm3, :comm4, :comm5, :comm6, :comm7, :comm8, :comm9, :comm10

  filter :quota_type
  filter :disabled

  index do
    selectable_column
    id_column
    column :code
    column :name
    column :rep_type
    column :quota_type
    column :disabled
    actions
  end

  show do |rep|
    attributes_table(title: "Sales Rep Details") do
      row :code
      row :name
      row("Commission Type") { rep.quota_type }
      row :rep_type
      row :disabled
    end

    columns do
      column do
        (1..5).each do |i|
          attributes_table(title: "Level #{i}") do
            row("Minimum GP %") { rep["goal#{i}"] }
            row("Commission %") { rep["comm#{i}"] }
          end
        end
      end

      column do
        (6..10).each do |i|
          attributes_table(title: "Level #{i}") do
            row("Minimum GP %") { rep["goal#{i}"] }
            row("Commission %") { rep["comm#{i}"] }
          end
        end
      end
    end

    attributes_table(title: "Aging Multipliers") do
      (1..5).each do |i|
        row("Period #{i} %") { rep["period#{i}"] }
      end
    end
  end

  form title: "Edit Sales Rep" do |_f|
    inputs "Sales Rep Details" do
      input :code
      input :name
      input :rep_type
      input :quota_type, as: :select, collection: SalesRep::QUOTA_TYPES, label: "Quota Type"
      input :disabled, type: :checkbox
    end

    columns do
      column do
        (1..5).each do |i|
          inputs "Level #{i}" do
            input :"goal#{i}", label: "Minimum GP %"
            input :"comm#{i}", label: "Commission %"
          end
        end
      end

      column do
        (6..10).each do |i|
          inputs "Level #{i}" do
            input :"goal#{i}", label: "Minimum GP %"
            input :"comm#{i}", label: "Commission %"
          end
        end
      end
    end

    inputs "Aging Multipliers" do
      (1..5).each do |i|
        input :"period#{i}", label: "Period #{i} %"
      end
    end

    actions
  end
end
