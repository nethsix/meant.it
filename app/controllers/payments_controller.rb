require 'constants'
require 'crypto42'
class PaymentsController < ApplicationController
  TRAN_CHARGE = 0.01
  def show
    pay_id = params[:pay_id]
    # Split billing to merchant and me
    
  end # end def show
end # end class PaymentsController < ApplicationController
