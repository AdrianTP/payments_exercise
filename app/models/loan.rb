class Loan < ActiveRecord::Base
  has_many :payments

  def outstanding_balance
    @outstanding_balance ||= funded_amount - payments.sum(:paid_amount)
  end

  def as_json(options={})
    opts = {
      :methods => [:outstanding_balance]
    }

    super(options.merge(opts))
  end
end
