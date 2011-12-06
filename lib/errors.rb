class PaymentException < RuntimeError
  attr :invoice_no
  def initialize(invoice_no)
    @invoice_no = invoice_no
  end # end def initialize
end
