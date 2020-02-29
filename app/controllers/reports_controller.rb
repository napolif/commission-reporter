class ReportsController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :cast_boolean_params

  def index
    render :index, locals: {batch_numbers: Invoice.batch_numbers}
  end

  def date
    render_report Invoice.where(paid_on: params[:from]..params[:to]).includes(:sales_rep)
  end

  def batch
    batch_num = if params[:batch_id] == "latest"
                  Invoice.latest_batch_number
                else
                  params[:batch_id]
                end

    render_report Invoice.where(batch: batch_num).includes(:sales_rep)
  end

  private

  def render_report(invoices)
    @one_per_page = true if params[:one_per_page]
    @list_disabled_reps = true if params[:list_disabled_reps]
    @presenter = ReportsShowPresenter.new(invoices)

    respond_to do |format|
      format.html do
        render :show, layout: "report"
      end

      format.pdf do
        margin = "0.75in"
        render pdf: "output",
               layout: "report",
               template: "reports/show",
               margin: {top: margin,
                        bottom: margin,
                        left: margin,
                        right: margin},
               print_media_type: true
      end

      format.csv do
        send_data(@presenter.as_csv,
                  filename: "commission-#{params[:batch_id]}-#{Date.today}.csv")
      end
    end
  end

  def cast_boolean_params
    cast_boolean_param(:grayscale)
    cast_boolean_param(:one_per_page)
    cast_boolean_param(:list_disabled_reps)
  end
end
