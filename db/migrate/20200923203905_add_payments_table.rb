class AddPaymentsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.decimal :paid_amount, precision: 8, scale: 2
      t.timestamps null: false
    end

    add_reference :payments, :loan, foreign_key: true
  end
end
