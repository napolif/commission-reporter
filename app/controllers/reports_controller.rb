class ReportsController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :cast_boolean_params

  PDF_OPTIONS = {layout: "report",
                 template: "reports/show",
                 margin: {top: "0.75in", bottom: "0.75in", left: "0.75in", right: "0.75in"},
                 print_media_type: true}.freeze

  def index
    render :index, locals: {batch_numbers: InvoiceSummary.batch_numbers}
  end

  def date
    # @title = "Report for #{params[:from]} to #{params[:to]}"
    # render_report InvoiceSummary.where(paid_on: params[:from]..params[:to])
    #                             .where("amount > ?", 0)
    #                             .includes(:sales_rep)

    @title = "Report for #{params[:from]} to #{params[:to]}"

    range = params[:from]..params[:to]
    all_ar = PurgedRecord.where(created_date: range)
                         .includes(invoice_header: [:sales_rep, :customer])
    good_ar = all_ar.where.not(invoice_headers: {id: nil})
                    # .where("invoice_headers.amount > ?", 0)
    render_report good_ar
  end

  # def batch
  #   batch_num = if params[:batch] == "latest"
  #                 InvoiceSummary.latest_batch_number
  #               else
  #                 params[:batch]
  #               end
  #
  #   @title = "Report for batch #{batch_num}"
  #   render_report Invoice.where(batch: batch_num).includes(:sales_rep)
  # end

  private

  def render_report(purgeds) # rubocop:disable Metrics/AbcSize
    @one_per_page = true if params[:one_per_page]
    @list_disabled_reps = true if params[:list_disabled_reps]
    @presenter = ReportsShowPresenter.new(purgeds)

    respond_to do |format|
      format.html do
        render :show
      end

      format.pdf do
        render pdf: "output", **PDF_OPTIONS.merge(grayscale: params[:grayscale])
      end

      format.csv do
        send_data(@presenter.as_csv,
                  filename: "commission-#{params[:batch]}-#{Date.today}.csv")
      end
    end
  end

  def cast_boolean_params
    cast_boolean_param(:grayscale)
    cast_boolean_param(:one_per_page)
    cast_boolean_param(:list_disabled_reps)
  end
end
