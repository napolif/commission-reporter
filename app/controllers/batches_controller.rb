class BatchesController < ApplicationController
  before_action :authenticate_admin_user!

  def upload
    uploader = UploadInvoicesCSV.new(params[:invoices])
    uploader.run

    if uploader.invalid?
      render :upload_fail, locals: {errors: uploader.errors}
      return
    end

    batch_number = uploader.result.first.batch
    report_url = by_batch_reports_path(batch_number)
    batch_size = Invoice.latest_batch.count

    render :upload_success, locals: {batch_number: batch_number,
                                     report_url: report_url,
                                     batch_size: batch_size}
  end
end