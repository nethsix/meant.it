class Payment < ActiveRecord::Base
  belongs_to :meant_it_rel

  validates :status, :presence => true, :payment_status_type => true
  validates :item_no, :presence => true
  validates :quantity, :presence => true

  after_initialize :default_values
#CODE This can be used to check that we either have xxxx or xxxx_rate
# where xxxx: {tax, discount} but not both
#  before_save :before_save_stuff

  private
    def default_values
      self.status ||= PaymentStatusTypeValidator::PAYMENT_STATUS_ACTIVE
    end # end def default_values
end
