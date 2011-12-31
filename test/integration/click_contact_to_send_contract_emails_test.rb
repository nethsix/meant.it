require 'test_helper'
require 'validators'
require 'constants'
require 'controller_helper'
require 'capybara/rails'
require 'date'
require 'rexml/document'

# PATCH : Start
# Needed otherwise Capybara is in a different transaction group
# from test so they cannot see the database entries/created by one another
class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end

# Forces all threads to share the same connection. This works on
# Capybara because it starts the web server in a thread.
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection 
# PATCH : End

class ClickContactToSendContractEmailsTest < ActionDispatch::IntegrationTest
  include Capybara::DSL

  fixtures :all

  READY_COL_NO = 7
  BILLED_COL_NO = 8

  # The default of :rack_test does not support javascript
  def setup
    Capybara.default_driver = :selenium
#    Capybara.app_host = "http://localhost:3000"
    capybara_common_selectors
  end # end

  # Replace this with your real tests.
  test "the truth" do
    assert true
  end

  test "send contract email for two mir with valid emails" do
    logtag = ControllerHelper.gen_logtag
    username = "nethsix@gmail.com"
    password = "password"
#20111206ABC    # Login
#20111206ABC    sess = login(username, password)
    # Login using capybara
#20111210 We don't need to login to send messages since we're using
#20111210 sendgrid url
#20111210    visit("/log_in")
#20111210    fill_in('session_login_name', :with => username)
#20111210    fill_in('session_password', :with => password)
#20111210    click_button('Sign In')
#20111210    info_msg_elem = find('#info')
#20111210    assert_not_nil(info_msg_elem)
#20111210    assert(info_msg_elem.text.match(/#{(Constants::LOGGED_IN_NOTICE)}/))
    # How much to inc currency value for each subsequent email
    inc_curr_val = 10
    pps_currency = "SGD"
    pps_threshold = 1000
    pps_threshold_type = PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_ONETIME
    pps_status = StatusTypeValidator::STATUS_ACTIVE
    value_type = ValueTypeValidator::VALUE_TYPE_VALUE
    pps_notify = "shopowner@bestshop.com"
    email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_currency_sender_idable_inbound_email)
    from_email_arr = Array.new
    # The first two emails will be from same sender
    email_hash = ControllerHelper.parse_email(email_elem.from)
    email_str = email_hash[ControllerHelper::EMAIL_STR]
    from_email_arr.push(email_str)
    from_email_arr.push(email_str)
    from_email2 = "something_new@somewhere.com"
    from_email_arr.push(from_email2)
    # Insert input_str of emails so that we can check later
    input_str_arr = Array.new
    # Set the path so that the "from:" email is used
    # otherwise sender is anonymous
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send contract email for two mir with valid emails:#{logtag}, page.inspect:#{page.inspect}")
#20111206ABC    sess.post_via_redirect "/inbound_emails_200", email_elem.attributes
    post_via_redirect "#{Constants::SENDGRID_PARSE_URL}", email_elem.attributes
# Used for debugging, this is another way to create an inbound_email entry
# but we need to login as admin first
#20111210 Post using anonymous
#20111210 visit("/inbound_emails/new")
#20111210 fill_in('inbound_email[headers]', :with => email_elem.headers)
#20111210 fill_in('inbound_email[envelope]', :with => email_elem.envelope)
#20111210 fill_in('inbound_email[from]', :with => email_elem.from)
#20111210 fill_in('inbound_email[to]', :with => email_elem.to)
#20111210 fill_in('inbound_email[subject]', :with => email_elem.body_text)
#20111210 fill_in('inbound_email[attachment_count]', :with => email_elem.attachment_count)
#20111210 # To change hidden values
#20111210 # page.evaluate_script('$("my/selector").val("haxxx")')
#20111210 click_button('Create Inbound email')
    input_str = email_elem.subject
    input_str ||= email_elem.body_text
    # Insert input_str for comparison later
    input_str_arr.push(input_str)
    sum_curr_val = ControllerHelper.sum_currency_in_str(input_str)
    start_curr_code, start_curr_val = ControllerHelper.get_currency_code_and_val(sum_curr_val)
    assert_equal(pps_currency, start_curr_code)
    input_str_hash = ControllerHelper.parse_meant_it_input(input_str)
    pii_str = input_str_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    pii = setup_pps_by_pii_value(pii_str, pps_currency, pps_threshold, pps_threshold_type, pps_status, value_type, pps_notify, logtag=nil)
# DEBUG : Start
# entity_1 = Entity.find(1)
# assert_not_nil(entity_1.endPoints)
# assert(1, entity_1.endPoints.size)
# endPoint_0 = entity_1.endPoints[0]
# assert(pii_str, endPoint_0.pii.pii_value)
# Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send contract email for two mir with valid emails:#{logtag}, entity_1.object_id:#{entity_1.object_id}")
# Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send contract email for two mir with valid emails:#{logtag}, entity_1.inspect:#{entity_1.inspect}")
# Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send contract email for two mir with valid emails:#{logtag}, entity_1.endPoints.inspect:#{entity_1.endPoints.inspect}")
# DEBUG : End
    # Send two emails to create two mirs associate with the pii
    email_elem1 = email_elem.dup
    pii_value, email_elem1_curr_val = change_value(email_elem1, inc_curr_val)
    email_elem2 = email_elem.dup
    email_elem2.from = from_email2
    pii_value, email_elem2_curr_val = change_value(email_elem2, inc_curr_val)
    # Insert input_str for comparison later
    input_str_email_elem1 = email_elem1.subject
    input_str_email_elem1 ||= email_elem1.body_text
    input_str_arr.push(input_str_email_elem1)
    input_str_email_elem2 = email_elem2.subject
    input_str_email_elem2 ||= email_elem2.body_text
    input_str_arr.push(input_str_email_elem2)
p "!!!!!!email_elem1_curr_val:#{email_elem1_curr_val}, email_elem2_curr_val:#{email_elem2_curr_val}"
#20111206ABC    sess.post_via_redirect "/inbound_emails_200", email_elem1.attributes
    post_via_redirect "#{Constants::SENDGRID_PARSE_URL}", email_elem1.attributes
#20111206ABC    sess.post_via_redirect "/inbound_emails_200", email_elem2.attributes
#02111211A    post_via_redirect "#{Constants::SENDGRID_PARSE_URL}", email_elem2.attributes
    pii.reload
    # Check email_bill_entries, mirs, etc.
    assert_equal(pii_value, pii_str)
    assert_equal(1, pii.pii_property_set.email_bill_entries.size)
    assert_equal(1, pii.pii_property_set.email_bill_entries[0].meant_it_rels.size)
    assert_equal((start_curr_val+inc_curr_val).to_f, pii.pii_property_set.email_bill_entries[0].qty.to_f)
    assert_equal(pps_currency, pii.pii_property_set.email_bill_entries[0].currency)
    first_bill = pii.pii_property_set.email_bill_entries[0]
    assert_nil(first_bill.ready_date)
    assert_nil(first_bill.billed_date)
    # Login using capybara
    hk_username = "hello_kitty"
    hk_password = "password"
    hk_sess = Capybara::Session.new(:selenium, Capybara.app)
    hk_sess.visit("/log_in")
    hk_sess.fill_in('session_login_name', :with => hk_username)
    hk_sess.fill_in('session_password', :with => hk_password)
    hk_sess.click_button('Sign In')
    hk_info_msg_elem = hk_sess.find_by_id('info')
    assert_not_nil(hk_info_msg_elem)
    assert(hk_info_msg_elem.text.match(/#{(Constants::LOGGED_IN_NOTICE)}/))
#AAA    visit("/log_in")
#AAA    fill_in('session_login_name', :with => hk_username)
#AAA    fill_in('session_password', :with => hk_password)
#AAA    click_button('Sign In')
#AAA    hk_info_msg_elem = find_by_id('info')
#AAA    assert_not_nil(hk_info_msg_elem)
#AAA    assert(hk_info_msg_elem.text.match(/#{(Constants::LOGGED_IN_NOTICE)}/))
    # Now simulate clicking on Contact
    hk_sess.click_link("Manage")
#AAA    click_link("Manage")
# DEBUG : Start
# entity_1 = Entity.find(1)
# assert_not_nil(entity_1.endPoints)
# assert(1, entity_1.endPoints.size)
# endPoint_0 = entity_1.endPoints[0]
# assert(pii_str, endPoint_0.pii.pii_value)
# Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send contract email for two mir with valid emails:#{logtag}, entity_1.object_id:#{entity_1.object_id}")
# Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send contract email for two mir with valid emails:#{logtag}, entity_1.inspect:#{entity_1.inspect}")
# Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send contract email for two mir with valid emails:#{logtag}, entity_1.endPoints.inspect:#{entity_1.endPoints.inspect}")
# DEBUG : End
#AAA    click_link("Bill")
#AAA    find(:row, 1)
    email_bill_a_href = nil
    hk_sess.within(:row, 1) do
      email_bill_a_href = hk_sess.find_link("Bill")[:href]
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send contract email for two mir with valid emails:#{logtag}, email_bill_a_href.inspect:#{email_bill_a_href.inspect}")
      hk_sess.click_link("Bill")
      email_registered_col = hk_sess.find(:row_col, Constants::EMAIL_BILL_EMAIL_REGISTERED_COL_NO)
      email_sent_col = hk_sess.find(:row_col, Constants::EMAIL_BILL_EMAIL_SENT_COL_NO)
      cost_col = hk_sess.find(:row_col, Constants::EMAIL_BILL_COST_COL_NO)
      ready_col = hk_sess.find(:row_col, Constants::EMAIL_BILL_READY_COL_NO)
      billed_col = hk_sess.find(:row_col, Constants::EMAIL_BILL_BILLED_COL_NO)
      actions_col = hk_sess.find(:row_col, Constants::EMAIL_BILL_ACTIONS_COL_NO)
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send contract email for two mir with valid emails:#{logtag}, cost_col.text:#{cost_col.text}")
      cost_col_numeric_arr = cost_col.text.match(/[0-9.]+/)
      cost_col_numeric = cost_col_numeric_arr[0]
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send contract email for two mir with valid emails:#{logtag}, cost_col_numeric:#{cost_col_numeric}")
      assert_equal(1, email_registered_col.text.to_i)
      assert_equal(0, email_sent_col.text.to_i)
      assert_equal(email_registered_col.text.to_f * Constants::EMAIL_COST.to_f,
                   cost_col_numeric.to_f)
      # Since it has not reached threshold, we expect it to hold
      # the percent of threshold
      threshold_ratio = ((start_curr_val.to_f + inc_curr_val.to_f) *100) / 
                        pps_threshold.to_f
      assert_equal("#{threshold_ratio}%", ready_col.text)
      assert_equal("", billed_col.text)
      assert_equal("Contact", actions_col.text)
    end # end hk_sess.within(:row, 1) do
    # Send send participating email
    datetime_before_bill = DateTime.now
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      post_via_redirect "#{Constants::SENDGRID_PARSE_URL}", email_elem2.attributes
    end # end assert_difference 'ActionMailer::Base.deliveries.size', +1 do
    threshold_email = ActionMailer::Base.deliveries.first
    assert_equal(pps_notify, threshold_email.to[0])
    assert_match(/Threshold of.*#{ControllerHelper.threshold_display_str_from_attr(pps_currency, pps_threshold)}.*pii:#{pii_value}.*reached/, threshold_email.subject)
    assert_match(/Congratulations.*Threshold of.*#{ControllerHelper.threshold_display_str_from_attr(pps_currency, pps_threshold)}.*pii:#{pii_value}.*reached/m, threshold_email.body.raw_source)
    pii.reload
    assert_equal(1, pii.pii_property_set.email_bill_entries.size)
    assert_equal(2, pii.pii_property_set.email_bill_entries[0].meant_it_rels.size)
    assert_equal(((start_curr_val + inc_curr_val) * 2),
                 pii.pii_property_set.email_bill_entries[0].qty)
    assert_equal(pps_currency, pii.pii_property_set.email_bill_entries[0].currency)
    first_bill = pii.pii_property_set.email_bill_entries[0]
    assert_not_nil(first_bill.ready_date)
    assert_nil(first_bill.billed_date)
    # Reload page
# NOTE: The default driver does not support javascript
# so by avoiding use of javascript we can run faster than using
# selenium.
#    hk_sess.evaluate_script('location.reload()')
    email_bill_a_href_url = URI::parse(email_bill_a_href)
    hk_sess.visit("#{email_bill_a_href_url.path}?#{email_bill_a_href_url.query}")
    expected_email_sent_count = nil
    hk_sess.within(:row, 1) do
      email_registered_col = hk_sess.find(:row_col, Constants::EMAIL_BILL_EMAIL_REGISTERED_COL_NO)
      expected_email_sent_count = email_registered_col.text
      email_sent_col = hk_sess.find(:row_col, Constants::EMAIL_BILL_EMAIL_SENT_COL_NO)
      cost_col = hk_sess.find(:row_col, Constants::EMAIL_BILL_COST_COL_NO)
      ready_col = hk_sess.find(:row_col, Constants::EMAIL_BILL_READY_COL_NO)
      billed_col = hk_sess.find(:row_col, Constants::EMAIL_BILL_BILLED_COL_NO)
      actions_col = hk_sess.find(:row_col, Constants::EMAIL_BILL_ACTIONS_COL_NO)
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send contract email for two mir with valid emails:#{logtag}, cost_col.text:#{cost_col.text}")
      cost_col_numeric_arr = cost_col.text.match(/[0-9.]+/)
      cost_col_numeric = cost_col_numeric_arr[0]
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send contract email for two mir with valid emails:#{logtag}, cost_col_numeric:#{cost_col_numeric}")
      assert_equal(2, email_registered_col.text.to_i)
      assert_equal(0, email_sent_col.text.to_i)
      assert_equal(email_registered_col.text.to_f * Constants::EMAIL_COST.to_f,
                   cost_col_numeric.to_f)
      # Since it has not reached threshold, we expect it to hold
      # a date
      displayed_billed_date = nil
      assert_nothing_raised(ArgumentError) {
                         displayed_billed_date = DateTime.parse(ready_col.text)
                       } # end assert_nothing_raised(ArgumentError) 
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send contract email for two mir with valid emails:#{logtag}, displayed_billed_date.inspect:#{displayed_billed_date.inspect}, datetime_before_bill.inspect:#{datetime_before_bill.inspect}")
      # The diff should not be greater than 5 seconds from the time
      # the 2nd email was sent
      assert_operator((displayed_billed_date - datetime_before_bill).to_f, "<", 5.to_f)
      assert_equal("", billed_col.text)
      assert_equal("Contact", actions_col.text)
      assert_difference 'ActionMailer::Base.deliveries.size', +2 do
        hk_sess.click_link("Contact")
      end # end assert_difference 'ActionMailer::Base.deliveries.size', +1 do
    end # end hk_sess.within(:row, 1) do
# DEBUG    hk_sess.save_and_open_page
    email_sent_info = hk_sess.find_by_id("info")
    assert_match(/#{expected_email_sent_count} emails sent/, email_sent_info.text)
    # Check the payment objects as well
    payment_objs_arr = Array.new
    MeantItRel.all.each { |mir_elem|
      if !mir_elem.payments.empty?
        payment_objs_arr.push(mir_elem.payments[0])
      else
        payment_objs_arr.push(nil)
      end # end if !mir_elem.payments.empty?
    } # end mirs.all.each ...
    # We expect two payments since we sent 3 emails but the first
    # creates the object so payment is nil
    assert_equal(3, payment_objs_arr.size)
    assert_nil(payment_objs_arr[0])
    (1..2).each { |idx|
      contract_email_elem = ActionMailer::Base.deliveries[idx]
      assert_match(/pii:#{pii_value}.*ready/, contract_email_elem.subject)
      assert_equal from_email_arr[idx], contract_email_elem.to[0]
      assert_match(/Congratulations.*Your order.*invoice #:#{payment_objs_arr[idx].invoice_no}.*pii:#{pii_value}.*succeed.*items:.*#{input_str_arr[idx]}/m, contract_email_elem.body.inspect.to_s)
#20111222 NOTE: We cannot use absolute url (http://.*) match since
#20111222 in testing we have not fix port so we cannot create absolute url
#20111222      assert_match(/<a href=.*http:\/\/.*\/payments\/pay\/invoice_no\/#{CGI::escape(payment_objs_arr[idx].invoice_no)}.*here<\/a>/m, contract_email_elem.body)
      assert_match(/<a href=.*\/payments\/pay\/invoice_no\/#{CGI::escape(payment_objs_arr[idx].invoice_no)}.*here<\/a>/m, contract_email_elem.body.inspect.to_s)
    } # end (1..2).each ...
    # Simulate user attempting to pay
    user_sess = Capybara::Session.new(:selenium, Capybara.app)
    # NOTE: 0 is the email to create the object not email to purchase
    contract_email_1 = ActionMailer::Base.deliveries[1]
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send contract email for two mir with valid emails:#{logtag}, contract_email_1.body.inspect:#{contract_email_1.body.inspect}")
    # Use REXML to parse the contract email html since we do 
    # simple parsing only
    rexml_doc = REXML::Document.new(contract_email_1.body.raw_source)
    a_elems = rexml_doc.elements.to_a("//a")
    # NOTE: To check on paypal page b'cos for 'Buy Now'
    # to succeed, we need to login using Selenium as well, which
    # requires us to login to Paypal 
    # HOWEVER, clicking on Test Account will open another page making
    # the entire process diff and fragile
#20111223     visit("http://developer.paypal.com")
#20111223     fill_in('login_email', :with => 'xxxx@yyyy.com')
#20111223     fill_in('login_password', :with => 'hahaha')
#20111223     click_button('Log In')
    # We expect only one a element
    assert_equal(1, a_elems.size)
    payment_link = a_elems[0].attribute('href')
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send contract email for two mir with valid emails:#{logtag}, payment_link:#{payment_link}")
    user_sess.visit(payment_link)
    assert(user_sess.has_content?("Invoice No.: #{payment_objs_arr[1].invoice_no}"))
    assert(user_sess.has_content?("Name: #{payment_objs_arr[1].item_name}"))
    assert(user_sess.has_content?("Item No.: #{payment_objs_arr[1].item_no}"))
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send contract email for two mir with valid emails:#{logtag}, payment_objs_arr[1].quantity:#{payment_objs_arr[1].quantity}")
    assert(user_sess.has_content?("Qty: #{payment_objs_arr[1].quantity}"))
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send contract email for two mir with valid emails:#{logtag}, payment_objs_arr[1].amount:#{payment_objs_arr[1].amount}")
    amount_display_str = ControllerHelper.threshold_display_str_from_attr(payment_objs_arr[1].currency_code, payment_objs_arr[1].amount, logtag)
    assert(user_sess.has_content?("Amount: #{amount_display_str}"))
    buynow_btn_elem = user_sess.find("#buynow_btn")
    buynow_btn_elem.click
  end # end  test "send contract email for two mir with valid emails" do

  test "invalid invoice number" do
    Capybara.default_driver = :rack_test
    payment_link = "/payments/pay/invoice_no/12345"
    visit(payment_link)
    assert(page.has_content?("Illegal invoice"))
    buynow_btn = find('#buynow_btn')
    assert_equal("true", buynow_btn[:disabled])
  end # end test "invalid invoice number" do
end
