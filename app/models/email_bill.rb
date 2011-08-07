class EmailBill < ActiveRecord::Base
  belongs_to :entity
  has_many :email_bill_entries
end
