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
    @title = "Report for #{params[:from]} to #{params[:to]}"

    numbers = PurgedRecord.where(created_date: params[:from]..params[:to])
                          .includes(:invoice_header)
                          .where.not(invoice_headers: {id: nil})
                          .pluck(:invoice_number)
                          .uniq

    payments = PurgedRecord.where(invoice_number: numbers)
                           .where(rep_code: included_rep_codes)
                           .includes(invoice_header: [:sales_rep, :customer])
                           .where(invoice_type: 2)

    render_report payments
  end

  private

  def render_report(purged_records) # rubocop:disable Metrics/AbcSize
    @one_per_page = true if params[:one_per_page]
    @list_disabled_reps = true if params[:list_disabled_reps]
    @presenter = ReportsShowPresenter.new(purged_records)

    respond_to do |format|
      format.html do
        render :show
      end

      format.pdf do
        render pdf: "output", **PDF_OPTIONS.merge(grayscale: params[:grayscale])
      end

      format.csv do
        send_data(@presenter.as_csv,
                  filename: "commission-report.csv")
      end
    end
  end

  def included_rep_codes
    if params[:rep_type]
      SalesRep.where(rep_type: params[:rep_type]).pluck(:code)
    else
      SalesRep.all.pluck(:code)
    end
  end

  def cast_boolean_params
    cast_boolean_param(:grayscale)
    cast_boolean_param(:one_per_page)
    cast_boolean_param(:list_disabled_reps)
  end
end
