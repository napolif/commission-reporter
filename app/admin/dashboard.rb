ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        img src: "/napoli.png", height: "80px"
        img src: "/ferraro.svg", height: "80px"
      end
    end

    columns do
      column do
        panel "Information" do
          para "Latest batch size: " + PaidInvoice.latest.count.to_s, class: "statistic"
          latest_date = PaidInvoice.latest.pluck(:invoiced_on).max.to_s
          para "Latest invoice from: " + latest_date, class: "statistic"
        end

        panel "Reports" do
          ul class: "reportList" do
            li class: "reportListItem" do
              span "Commission Report - Latest", class: "reportName"
              span link_to("HTML", report_path("latest"),
                           class: "formatLink-html")
              span link_to("PDF", report_path("latest", format: :pdf),
                           class: "formatLink-pdf js-pdfLink")
            end
            PaidInvoice.batch_numbers.sort.reverse.each do |num|
              li class: "reportListItem" do
                span "Commission Report - #{num}", class: "reportName"
                span link_to("HTML", report_path(num),
                             class: "formatLink-html")
                span link_to("PDF", report_path(num, format: :pdf),
                             class: "formatLink-pdf js-pdfLink")
              end
            end
          end
        end

        panel "PDF Options", class: "optionsPanel" do
          input type: "checkbox", class: "js-onePerPage", name: "one_per_page"
          label "Break page after each rep", for: "one_per_page"
          br
          input type: "checkbox", class: "js-grayscale", name: "grayscale"
          label "Grayscale", for: "grayscale"
          br
          input type: "checkbox", class: "js-listDisabledReps", name: "list_disabled_reps"
          label "List disabled reps on summary", for: "list_disabled_reps"
        end
      end
    end
  end
end
