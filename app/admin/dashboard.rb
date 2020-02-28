ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        img src: "/ferraro.svg", height: "80px"
        img src: "/napoli.png", height: "80px"
      end
    end

    panel "Information" do
      para "Build: %s" % Rails.configuration.x.commit_hash, class: "statistic"
      para "Latest batch size: " + Invoice.latest_batch.count.to_s, class: "statistic"
      latest_date = Invoice.latest_batch.pluck(:invoiced_on).max.to_s
      para "Latest invoice from: " + latest_date, class: "statistic"
    end

    panel "Reports" do
      ul class: "reportList" do
        Invoice.batch_numbers.sort.reverse.each do |num|
          li class: "reportListItem" do
            span "Commission Report - #{num}", class: "reportName"
            span link_to("HTML", by_batch_reports_path(num),
                         class: "formatLink-html js-htmlLink")
            span link_to("PDF", by_batch_reports_path(num, format: :pdf),
                         class: "formatLink-pdf js-pdfLink")
            span link_to("CSV", by_batch_reports_path(num, format: :csv),
                         class: "formatLink-csv")
          end
        end
      end
    end

    panel "Options", class: "optionsPanel" do
      input type: "checkbox", class: "js-listDisabledReps", name: "list_disabled_reps"
      label "List disabled reps in summary", for: "list_disabled_reps"
      br
      input type: "checkbox", class: "js-onePerPage", name: "one_per_page"
      label "Break page after each rep (PDF)", for: "one_per_page"
      br
      input type: "checkbox", class: "js-grayscale", name: "grayscale"
      label "Grayscale (PDF)", for: "grayscale"
    end
  end
end
