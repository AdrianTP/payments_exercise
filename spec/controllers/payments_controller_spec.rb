require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do
  let(:actual_body) { JSON.parse(response.body) }

  before { Timecop.freeze(Time.local(2020, 9, 24, 15, 54, 00)) }

  after { Timecop.return }

  describe '#index' do
    let(:loan_1) { Loan.create!(funded_amount: 100.0) }
    let(:loan_2) { Loan.create!(funded_amount: 500.0) }

    let(:loan_1_expected_body) do
      [
        {
          'created_at' => '2020-09-24T20:54:00.000Z',
          'id' => 1,
          'loan_id' => 1,
          'paid_amount' => '25.0',
          'updated_at' => '2020-09-24T20:54:00.000Z'
        },
        {
          'created_at' => '2020-09-24T20:54:00.000Z',
          'id' => 2,
          'loan_id' => 1,
          'paid_amount' => '70.0',
          'updated_at' => '2020-09-24T20:54:00.000Z'
        }
      ]
    end

    let(:loan_2_payment) do
      {
        'created_at' => '2020-09-24T20:54:00.000Z',
        'id' => 3,
        'loan_id' => 2,
        'paid_amount' => '100.0',
        'updated_at' => '2020-09-24T20:54:00.000Z'
      }
    end

    before do
      loan_1.payments.create!(paid_amount: 25.0)
      loan_1.payments.create!(paid_amount: 70.0)
      loan_2.payments.create!(paid_amount: 100.0)

      get :index, params: { loan_id: loan_1.id }
    end

    it 'returns a success response' do
      expect(response).to have_http_status(:ok)
    end

    it 'includes in the response body all payments associated with the specified loan' do
      expect(actual_body).to eq(loan_1_expected_body)
    end

    it 'does not include payments associated with other loans' do
      expect(actual_body).not_to include(loan_2_payment)
    end
  end

  describe '#show' do
    let(:loan) { Loan.create!(funded_amount: 100.0) }
    let(:payment) { loan.payments.create!(paid_amount: 25.0) }

    before { get :show, params: { id: payment_id } }

    context 'if a payment exists with the specified id' do
      let(:payment_id) { payment.id }

      let(:expected_body) do
        {
          'created_at' => '2020-09-24T20:54:00.000Z',
          'id' => 1,
          'loan_id' => 1,
          'paid_amount' => '25.0',
          'updated_at' => '2020-09-24T20:54:00.000Z'
        }
      end

      it 'returns a success response' do
        expect(response).to have_http_status(:ok)
      end

      it 'includes the payment information in the response body' do
        expect(actual_body).to eq(expected_body)
      end
    end

    context 'if no payment exists with the specified id' do
      let(:payment_id) { 10000 }

      it 'returns a "not found" response' do
        expect(response).to have_http_status(:not_found)
      end

      it 'includes no loan information in the response body' do
        expect(actual_body).to eq({})
      end
    end
  end

  describe '#create' do
    let(:loan) { Loan.create!(funded_amount: 100.0) }

    before { post :create, params: { loan_id: loan.id, amount: amount } }

    context 'with payment amount less than outstanding balance' do
      let(:amount) { '99.9' }

      let(:expected_body) do
        {
          'created_at' => '2020-09-24T20:54:00.000Z',
          'id' => 1,
          'loan_id' => 1,
          'paid_amount' => amount,
          'updated_at' => '2020-09-24T20:54:00.000Z'
        }
      end

      it 'returns a success response' do
        expect(response).to have_http_status(:created)
      end

      it 'includes the payment amount in the response body' do
        expect(actual_body).to eq(expected_body)
      end
    end

    context 'with payment amount more than outstanding balance' do
      let(:amount) { '100.1' }

      let(:expected_body) do
        {
          'errors' => {
            'amount' => [ 'must be less than 100.0' ]
          }
        }
      end

      it 'returns an unprocessable entity response' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'includes a meaningful error message in the response body' do
        expect(actual_body).to eq(expected_body)
      end
    end
  end
end
