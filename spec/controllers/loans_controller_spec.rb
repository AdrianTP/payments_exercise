require 'rails_helper'

RSpec.describe LoansController, type: :controller do
  let(:actual_body) { JSON.parse(response.body) }

  before { Timecop.freeze(Time.local(2020, 9, 24, 15, 54, 00)) }

  after { Timecop.return }

  describe '#index' do
    let(:outstanding_balance) { '100.0' }

    let(:expected_body) do
      [
        {
          'created_at' => '2020-09-24T20:54:00.000Z',
          'funded_amount' => '100.0',
          'id' => 1,
          'outstanding_balance' => outstanding_balance,
          'updated_at' => '2020-09-24T20:54:00.000Z'
        }
      ]
    end

    before do
      Loan.create!(funded_amount: 100.0)

      get :index
    end

    it 'returns a success response' do
      expect(response).to have_http_status(:ok)
    end

    it 'includes all loans in the response body' do
      expect(actual_body).to eq(expected_body)
    end

    context 'when payments have been made' do
      before do
        Loan.first.payments.create!(paid_amount: 50.0)

        get :index
      end

      it 'reflects the payments in the outstanding_balance' do
        expect(actual_body.first['outstanding_balance']).to eq('50.0')
      end
    end
  end

  describe '#show' do
    let(:loan) { Loan.create!(funded_amount: 100.0) }

    before { get :show, params: { id: id } }

    context 'if a loan exists with the specified id' do
      let(:id) { loan.id }

      let(:expected_body) do
        {
          'created_at' => '2020-09-24T20:54:00.000Z',
          'funded_amount' => '100.0',
          'id' => 1,
          'outstanding_balance' => '100.0',
          'updated_at' => '2020-09-24T20:54:00.000Z'
        }
      end

      it 'returns a success response' do
        expect(response).to have_http_status(:ok)
      end

      it 'includes the loan information in the response body' do
        expect(actual_body).to eq(expected_body)
      end

      context 'when payments have been made' do
        before do
          loan.payments.create!(paid_amount: 50.0)

          get :show, params: { id: id }
        end

        it 'reflects the payments in the outstanding_balance' do
          expect(actual_body['outstanding_balance']).to eq('50.0')
        end
      end
    end

    context 'if no loan exists with the specified id' do
      let(:id) { 10000 }

      it 'returns a "not found" response' do
        expect(response).to have_http_status(:not_found)
      end

      it 'includes no loan information in the response body' do
        expect(actual_body).to eq({})
      end
    end
  end
end
