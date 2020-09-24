class PaymentsController < ActionController::API

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: 'not_found', status: :not_found
  end

  def index
    render json: Payment.where(loan_id: params[:loan_id]).all
  end

  def show
    render json: Payment.find(params[:id])
  end

  def create
    if loan.outstanding_balance > params[:amount].to_f
      render status: :created, json: loan.payments.create!(paid_amount: params[:amount])
    else
      error_body = {
        errors: {
          amount: [ "must be less than #{loan.outstanding_balance}" ]
        }
      }

      render status: :unprocessable_entity, json: error_body
    end
  end

  def loan
    Loan.find(params[:loan_id])
  end
end
