class LoansController < ActionController::API

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render status: :not_found, json: {}
  end

  def index
    render json: Loan.all
  end

  def show
    render json: Loan.find(params[:id])
  end
end
