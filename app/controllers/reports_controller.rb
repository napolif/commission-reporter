class ReportsController < ApplicationController
  before_action :authenticate_admin_user!
  before_action :cast_boolean_params

  def show
    @one_per_page = true if params[:one_per_page]
    @list_disabled_reps = true if params[:list_disabled_reps]
    @presenter = ReportsShowPresenter.new(params[:batch])

    respond_to do |format|
      format.html
      format.csv do
        send_data(@presenter.as_csv,
                  filename: "commission-#{params[:batch]}-#{Date.today}.csv")
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
