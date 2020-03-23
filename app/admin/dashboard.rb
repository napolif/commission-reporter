ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do

    panel "Information" do
      para "Build: %s" % Rails.configuration.x.commit_hash, class: "statistic"

      latest_date = InvoiceHeader.maximum(:order_date)
      para "Latest invoice from: " + latest_date.to_s, class: "statistic"
    end

    panel "Totals" do
      para "Invoice Headers: " + InvoiceHeader.count.to_s, class: "statistic"
      para "Purged A/R Records: " + PurgedRecord.count.to_s, class: "statistic"
      para "Sales Reps: " + SalesRep.count.to_s, class: "statistic"
      para "Customers: " + Customer.count.to_s, class: "statistic"
    end

    panel "Exit Admin" do
      a "Go to Reports Dashboard", href: reports_path
    end
  end
end
