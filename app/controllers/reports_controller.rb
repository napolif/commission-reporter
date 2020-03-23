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

  def date # rubocop:disable Metrics/AbcSize
    @title = "Report for #{params[:from]} to #{params[:to]}"
    @one_per_page = true if params[:one_per_page]
    @list_disabled_reps = true if params[:list_disabled_reps]
    @presenter = ReportsShowPresenter.new(purged_records: purged_records,
                                          rep_codes: rep_codes)

    respond_to do |format|
      format.html do
        render :show
      end

      format.pdf do
        render pdf: "commission-report",
                    **PDF_OPTIONS.merge(grayscale: params[:grayscale])
      end

      format.csv do
        send_data(CommissionsCSV.new(@presenter.commissions).generate,
                  filename: "commission-report.csv")
      end
    end
  end

  private

  def purged_records
    PurgedRecord.for_dates_and_reps(params[:from]..params[:to],
                                    rep_codes)
  end

  def rep_codes
    SalesRep.by_type(params[:rep_type] || "all").codes
  end

  def cast_boolean_params
    cast_boolean_param(:grayscale)
    cast_boolean_param(:one_per_page)
    cast_boolean_param(:list_disabled_reps)
  end
end
