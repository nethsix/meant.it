class EmailBillEntry < ActiveRecord::Base
  belongs_to :pii_property_set
  belongs_to :email_bill

  has_many :meant_it_rels
end
