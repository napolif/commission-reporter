ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        img src: '/napoli.png', height: '80px'
        img src: '/ferraro.svg', height: '80px'
      end
    end

    columns do
      column do
        panel 'Reports' do
          ul class: 'dashboard_ul' do
            li link_to('Comission Report - Latest', '/reports/latest')
            PaidInvoice.batch_numbers.sort.reverse.each do |num|
              li link_to("Comission Report - #{num}", "/reports/#{num}")
            end
          end

        end
      end
    end

  end
end
