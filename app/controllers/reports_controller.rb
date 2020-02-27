class ReportsController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :cast_boolean_params

  def index
  end

  def date
    render plain: [params[:date_from], params[:date_to]]
  end

  def batch
    @one_per_page = true if params[:one_per_page]
    @list_disabled_reps = true if params[:list_disabled_reps]
    @presenter = ReportsShowPresenter.new(params[:batch_id])

    respond_to do |format|
      format.html do
        render :show, layout: "report"
      end

      format.csv do
        send_data(@presenter.as_csv,
                  filename: "commission-#{params[:batch_id]}-#{Date.today}.csv")
      end
    end
  end

  private

  def cast_boolean_params
    cast_boolean_param(:grayscale)
    cast_boolean_param(:one_per_page)
    cast_boolean_param(:list_disabled_reps)
  end
end
