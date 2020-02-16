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
            li do
              span "Commission Report - Latest", class: "reportName"
              span link_to("HTML", report_path("latest"), class: "formatLink-html")
              span link_to("PDF", report_path("latest", format: :pdf), class: "formatLink-pdf")
            end
            PaidInvoice.batch_numbers.sort.reverse.each do |num|
              li do
                span "Commission Report - #{num}", class: "reportName"
                span link_to("HTML", report_path(num), class: "formatLink-html")
                span link_to("PDF", report_path(num, format: :pdf), class: "formatLink-pdf")
              end
            end
          end
        end
      end
    end
  end
end
