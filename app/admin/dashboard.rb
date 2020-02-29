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
  end
end
