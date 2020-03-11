class BatchesController < ApplicationController
  before_action :authenticate_admin_user!

  def show
    unless params[:id].in? InvoiceSummary.batch_numbers
      raise ActiveRecord::RecordNotFound
    end

    @title = "Invoice Batch #{params[:id]}"
    @invoices = InvoiceSummary.where(batch: params[:id])
  end

  def upload
    uploader = ImportInvoiceSummariesCSV.new(params[:invoices])
    uploader.run

    if uploader.invalid?
      render :upload_fail, locals: {errors: uploader.errors}
      return
    end

    batch_number = uploader.result.first.batch
    flash[:notice] = "Upload Succeeded."
    redirect_to batch_path(batch_number)
  end
end
