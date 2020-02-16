class ReportsController < ApplicationController
  def show
    @data = report_data
    @one_per_page = true if params[:one_per_page]
  end

  private

  def report_data
    invs_by_rep = invoices.group_by(&:sales_rep)
    invs_by_rep.transform_values do |invs|
      invs.map { |inv| Commission.new(inv) }
    end
  end

  def invoices
    if params[:batch] == "latest"
      PaidInvoice.latest.includes(:sales_rep)
    else
      PaidInvoice.where(batch: params[:batch]).includes(:sales_rep)
    end
  end
end
