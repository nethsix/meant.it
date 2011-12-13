require 'constants'
require 'validators'
require 'crypto42'
class PaymentsController < ApplicationController
  TRAN_CHARGE = 0.01
  FAILED_INVOICE_NO = 0

  # Paypal variables
  # Cert uploaded to account, login and 
  # goto 'Profile' -> 'Encrypted Payment Settings'
  PP_CERT_ID = "RCPX3HG4PLNLE"
  # Paypal account
  PP_BUSINESS = "neth_12345@yahoo.com"
  # Billing country
  PP_COUNTRY = "SG"
  # These API endpoints are from: 
  # https://cms.paypal.com/us/cgi-bin?cmd=_render-content&content_ID=developer/howto_api_endpoints
  PAYPAL_SANDBOX_URL = "https://www.paypal.com/cgi-bin/webscr"
  PAYPAL_PRODUCTION_URL = "https://www.sandbox.paypal.com/cgi-bin/webscr"
  RETURN_URL_BASE = "http://#{request.domain}/payments/show/"
  ERROR_URL_BASE = "http://#{request.domain}/payments/error/"
  CANCEL_URL_BASE = "http://#{request.domain}/payments/cancel/"
  NOTIFY_URL = "http://#{request.domain}/payments/ipn"

  def cancel
    invoice_no = params[Constants::INVOICE_NO_INPUT]
    invoice_no ||= params[:invoice_no]
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:cancel:#{logtag}, invoice_no:#{invoice_no}")
    # If we want to track whose payment is cancelled then
    # use session
    # What objects are available from url_parms?!?!?!
    # Let's see
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:cancel:#{logtag}, params.inspect:#{params.inspect}")
    # By convention, cancel.html.erb will be rendered
  end # end def cancel

  def pay
    logtag = ControllerHelper.gen_logtag
    invoice_no = params[Constants::INVOICE_NO_INPUT]
    payment = Payment.find_by_invoice_no(invoice_no)
    # Prepare payment to be submitted to paypal
    fetch_decrypted(payment, logtag)
    respond_to do |format|
      format.html {
        render "pay", :layout => "payment"
      } # end format.html
    end # end respond_to do |format|
  end # end def pay

  def ipn
    # Create a notify object we must
    notify = Paypal::Notification.new(request.raw_post)
 
#CODE20111.. how to differentiate btwn successful return, look at rc
#CODE20111.. what is available from notification object
#CODE20111.. if success, store return_code, message, update payment_status
#CODE20111.. if cancel, store code, message, update payment_status
#CODE20111.. if ipn!?!? same as success?

    # We must make sure this transaction id is not allready completed
#CODE20111.. chant Trans to Payments
    if !Trans.count("*", :conditions => ["paypal_transaction_id = ?", notify.transaction_id]).zero?
      # Do some logging here...
    end # end if !Trans.count("*", :conditions => ["paypal_transaction_id = ?", notify.transaction_id]).zero?
   
    if notify.acknowledge
      begin
        if notify.complete?
          # Transaction complete.. add your business logic here
        else
          # Reason to be suspicious
        end # end if notify.complete?
      rescue => e
        # Houston we have a bug
      ensure
        # Make sure we logged everything we must
      end # end rescue errors during notification
    else # Transaction was not acknowledged
      # Another reason to be suspicious
    end # end if notify.acknowledge
   
    render :nothing => true
  end # end def ipn

  # GET /payments
  # GET /payments.xml
  def index
    @payments = Payment.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @payments }
    end
  end

  # GET /payments/1
  # GET /payments/1.xml
  def show
    @payment = Payment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @payment }
    end
  end

  # GET /payments/new
  # GET /payments/new.xml
  def new
    @payment = Payment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @payment }
    end
  end

  # GET /payments/1/edit
  def edit
    @payment = Payment.find(params[:id])
  end

  # POST /payments
  # POST /payments.xml
  def create
    @payment = Payment.new(params[:payment])

    respond_to do |format|
      if @payment.save
        format.html { redirect_to(@payment, :notice => 'Payment was successfully created.') }
        format.xml  { render :xml => @payment, :status => :created, :location => @payment }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @payment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /payments/1
  # PUT /payments/1.xml
  def update
    @payment = Payment.find(params[:id])

    respond_to do |format|
      if @payment.update_attributes(params[:payment])
        format.html { redirect_to(@payment, :notice => 'Payment was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @payment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /payments/1
  # DELETE /payments/1.xml
  def destroy
    @payment = Payment.find(params[:id])
    @payment.destroy

    respond_to do |format|
      format.html { redirect_to(payments_url) }
      format.xml  { head :ok }
    end
  end

  private

  # Create the encrypted button and set the form action url
  # +:job:+:: is the payment we want to make
  def fetch_decrypted(payment=nil, logtag=nil)
    # Update payment with information such as payee, country, etc.
    payment.payee = PP_BUSINESS
    payment.country = PP_COUNTRY
    unless payment.save
      logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:fetch_decrypted:#{logtag}, payment modification failed, payment.errors.inspect:#{payment.errors.inspect}")
      raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:fetch_decrypted:#{logtag}, payment modification failed, payment.errors.inspect:#{payment.errors.inspect}"
    end # end unless payment.save
    # cert_id is the certificate if we see in paypal when we upload our own certificates
    # cmd _xclick need for buttons
    # item name is what the user will see at the paypal page
    # custom and invoice are passthrough vars which we will 
    # get back with the asunchronous notification
    # no_note and no_shipping means the client want see 
    # these extra fields on the paypal payment page
    # return is the url the user will be redirected to by 
    # paypal when the transaction is completed.
    decrypted = {
      "cert_id" => PP_CERT_ID,
      "cmd" => "_xclick",
      "business" => PP_BUSINESS,
      "item_name" => payment.item_name,
      "item_number" => payment.item_number, 
      "custom" =>"something to pass to IPN",
      "amount" => payment.amount,
      "currency_code" => payment.currency_code,
      "country" => PP_COUNTRY,
      # Don't prompt for note
      "no_note" => "1",
      # Don't prompt for shipping, since we have
      "no_shipping" => "1",
      # IPN tells us the status of payment
      "notify_url" => NOTIFY_URL,
      # If user cancels payment before completing it
      "cancel_return" => "#{CANCEL_URL_BASE}/invoice_no/#{invoice_no}",
      "invoice" => payment.invoice_no, 
      "return" => "#{RETURN_URL_BASE}/#{Constants::INVOICE_NO_INPUT}/#{invoice_no}",
    } # end decrypted
     
    @encrypted_basic = Crypto42::Button.from_hash(decrypted).get_encrypted_text

    @action_url = ENV['RAILS_ENV'] == "production" ? PAYPAL_PRODUCTION_URL : PAYPAL_SANDBOX_URL
  end # end def fetch_decrypted
end
