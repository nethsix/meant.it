class EmailBillEntry < ActiveRecord::Base
  belongs_to :pii_property_set
  belongs_to :email_bill
end
