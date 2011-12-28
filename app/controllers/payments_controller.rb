require 'constants'
require 'validators'
#require 'active_merchant'
require 'crypto42'
#require 'money

class PaymentsController < ApplicationController
  include ActiveMerchant::Billing::Integrations

  TRAN_CHARGE = 0.01
  FAILED_INVOICE_NO = 0

  # Paypal variables
  # Cert uploaded to account, login and 
  # goto 'Profile' -> 'Encrypted Payment Settings'
  PP_PRODUCTION_CERT_ID = "RCPX3HG4PLNLE"
  PP_SANDBOX_CERT_ID = "8EJUTFDCDWUFY"
  # Paypal account
  PP_SANDBOX_BUSINESS = "pp2_1320488148_biz@yahoo.co.jp"
  PP_PRODUCTION_BUSINESS = "neth_12345@yahoo.com"
  # Billing country
  PP_COUNTRY = "US"
  # These API endpoints are from: 
  # https://cms.paypal.com/us/cgi-bin?cmd=_render-content&content_ID=developer/howto_api_endpoints
  PAYPAL_PRODUCTION_URL = "https://www.paypal.com/cgi-bin/webscr"
  PAYPAL_SANDBOX_URL = "https://www.sandbox.paypal.com/cgi-bin/webscr"
  RELATIVE_RETURN_URL_BASE = "/payments/pay/"
  RELATIVE_ERROR_URL_BASE = "/payments/error/"
  RELATIVE_CANCEL_URL_BASE = "/payments/pay/"
  RELATIVE_NOTIFY_URL = "/payments/ipn_pp_20111224"

  # Paypal status
  PAYPAL_STATUS_COMPLETED = "Completed"

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
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:pay:#{logtag}, invoice_no:#{invoice_no}")
    payment = Payment.find_by_invoice_no(invoice_no)
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:pay:#{logtag}, Payment.all.inspect:#{Payment.all.inspect}")
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:pay:#{logtag}, payment.inspect:#{payment.inspect}")
    if !payment.nil?
      amount_display_str = ControllerHelper.threshold_display_str_from_attr(payment.currency_code, payment.amount, logtag)
      if !payment.pp_status.nil? and !payment.pp_status.empty?
        respond_to do |format|
          format.html {
            # CODE: We need a better payment date instead of last_modified
            render "pay", :layout => "payment", :locals => { :error_msg => nil, :notice => nil, :invoice_no => invoice_no, :item_name => payment.item_name, :item_no => payment.item_no, :quantity => payment.quantity, :amount => amount_display_str, :payment_updated_at => payment.updated_at, :payment_created_at => payment.created_at, :payment_status => payment.pp_status, :trans_id => payment.pp_trans_id }
          } # end format.html
        end # end respond_to do |format|
      else
        # Prepare payment to be submitted to paypal
        fetch_decrypted(payment, logtag)
        respond_to do |format|
          format.html {
            render "pay", :layout => "payment", :locals => { :error_msg => nil, :notice => nil, :invoice_no => invoice_no, :item_name => payment.item_name, :item_no => payment.item_no, :quantity => payment.quantity, :amount => amount_display_str, :payment_updated_at => nil, :payment_created_at => nil, :payment_status => Constants::PAYPAL_STATUS_UNPAID, :trans_id => nil }
          } # end format.html
        end # end respond_to do |format|
      end # end else payment.pp_status != PAYPAL_STATUS_COMPLETED
    else
      respond_to do |format|
        format.html {
          error_msg = "Illegal invoice number"
          render "pay", :layout => "payment", :locals => { :error => error_msg , :error_msg => error_msg,  :invoice_no => "NA", :item_name => "NA", :item_no => "NA", :quantity => "NA", :amount => "NA", :payment_date => nil }
        } # end format.html
      end # end respond_to do |format|
    end # end if !payment.nil?
  end # end def pay

  def ipn
    logtag = ControllerHelper.gen_logtag
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:ipn:#{logtag}, params.inspect:#{params.inspect}")
p "ipn, params.inspect:#{params.inspect}"
    # Create a notify object we must
    notify = Paypal::Notification.new(request.raw_post)
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:ipn:#{logtag}, notify.inspect:#{notify.inspect}")
p "ipn, notify.inspect:#{notify.inspect}"

    # Save ipn response
    invoice_no = params[:invoice]
    payment = Payment.find_by_invoice_no(invoice_no)
    # Check if this transaction has been completed before
    if payment.pp_status == PAYPAL_STATUS_COMPLETED
      logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:ipn:#{logtag}, payment (id:#{payment.id}) transaction completed with pp_trans_id:#{payment.pp_trans_id}")
    else
      payment.pp_ipn_parms = params
      payment.pp_status = params[:payment_status]
      payment.pp_trans_id = params[:txn_id]
      unless payment.save
        logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:ipn:#{logtag}, payment.save failed when adding pp_ipn_parms field, payment.errors.inspect:#{payment.errors.inspect}")
        logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:ipn:#{logtag}, payment.save failed, ipn parms:#{params.inspect}")
      end # end unless payment.save
      if notify.acknowledge
        begin
          if notify.complete?
            # Transaction complete.. add your business logic here
          else
            # Reason to be suspicious
            logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:ipn:#{logtag}, payment (id:#{payment.id}) incomplete, payment.pp_ipn_parms.inspect:#{payment.pp_ipn_parms.inspect}")
          end # end if notify.complete?
        rescue => e
          # Houston we have a bug
        ensure
          # Make sure we logged everything we must
        end # end rescue errors during notification
      else # Transaction was not acknowledged
        # Another reason to be suspicious
      end # end if notify.acknowledge
    end # end if payment.pp_trans_id.nil?
 
#CODE20111.. how to differentiate btwn successful return, look at rc
#CODE20111.. what is available from notification object
#CODE20111.. if success, store return_code, message, update payment_status
#CODE20111.. if cancel, store code, message, update payment_status
#CODE20111.. if ipn!?!? same as success?
#20111223 NOTE: We do this above
#20111223    # We must make sure this transaction id is not allready completed
#20111223    if !Trans.count("*", :conditions => ["paypal_transaction_id = ?", notify.transaction_id]).zero?
#20111223      # Do some logging here...
#20111223    end # end if !Trans.count("*", :conditions => ["paypal_transaction_id = ?", notify.transaction_id]).zero?
   
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
    payment.payee = pp_business_type
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
    cert_id = cert_id_type
    pp_business = pp_business_type
    decrypted = {
      "cert_id" => cert_id,
      "cmd" => "_xclick",
      "business" => pp_business,
      "item_name" => payment.item_name,
      "item_number" => payment.item_no, 
      "custom" =>"something to pass to IPN",
      "amount" => payment.amount,
      "currency_code" => payment.currency_code,
#DEBUG      "currency_code" => "JPY",
      "country" => PP_COUNTRY,
      # Don't prompt for note
      "no_note" => "1",
      # Don't prompt for shipping, since we have
      "no_shipping" => "1",
      # IPN tells us the status of payment
      "notify_url" => "http://#{request.domain}#{RELATIVE_NOTIFY_URL}",
#DEBUG      "notify_url" => "http://meant.it",
      # If user cancels payment before completing it
     "cancel_return" => "http://#{request.domain}#{RELATIVE_CANCEL_URL_BASE}#{Constants::INVOICE_NO_INPUT}/#{payment.invoice_no}",
#DEBUG      "cancel_return" => "http://meant.it",
      "invoice" => payment.invoice_no, 
      "return" => "http://#{request.domain}#{RELATIVE_RETURN_URL_BASE}#{Constants::INVOICE_NO_INPUT}/#{payment.invoice_no}",
#DEBUG      "return" => "http://meant.it"
      # Call return URL using GET. Somehow Paypal is using POST.
      "rm" => 1,
    } # end decrypted
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:fetch_decrypted:#{logtag}, decrypted.inspect:#{decrypted.inspect}")
p "decrypted.inspect:#{decrypted.inspect}"
     
    @encrypted_basic = Crypto42::Button.from_hash(decrypted).get_encrypted_text

    @action_url = action_url_type
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:fetch_decrypted:#{logtag}, @action_url:#{@action_url}")
  end # end def fetch_decrypted

  def cert_id_type
#20111223PP    cert_id = ENV['RAILS_ENV'] == "production" ? PP_PRODUCTION_CERT_ID : PP_SANDBOX_CERT_ID
    cert_id = PP_SANDBOX_CERT_ID
    cert_id
  end # end def cert_id_type

  def action_url_type
#20111223PP    action_url = ENV['RAILS_ENV'] == "production" ? PAYPAL_PRODUCTION_URL : PAYPAL_SANDBOX_URL
    action_url = PAYPAL_SANDBOX_URL
    action_url
  end # end def action_url_type

  def pp_business_type
#20111223PP    pp_business = ENV['RAILS_ENV'] == "production" ? PP_PRODUCTION_BUSINESS : PP_SANDBOX_BUSINESS
    pp_business = PP_SANDBOX_BUSINESS
    pp_business
  end # end def pp_business_type
end
