require 'test_helper'
require 'validators'
require 'controller_helper'

class ClickContactToSendContractEmailsTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  fixtures :all

  # Replace this with your real tests.
  test "the truth" do
    assert true
  end

  test "send contract email for two mir with valid emails" do
    logtag = ControllerHelper.gen_logtag
    username = "nethsix@gmail.com"
    password = "password"
    # Login
#20111205ABC    open_session do |sess|
#20111205ABC# If we want to emulate https
#20111205ABC#      sess.https!
#20111205ABC      sess.post_via_redirect "/sessions", "session[login_name]" => username, "session[password]" => password
#20111205ABC      assert_equal '/pqpq', sess.path
#20111205ABC      assert_equal Constants::LOGGED_IN_NOTICE, flash[:notice]
#20111205ABC# Unemulate https
#20111205ABC#      sess.https!(false)
#20111205ABC    end # end open_session do ...
#20111205ERR    login(username, password)
    sess = login(username, password)
    pps_currency = "SGD"
    pps_threshold = 1000
    pps_threshold_type = PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_ONETIME
    pps_status = StatusTypeValidator::STATUS_ACTIVE
    value_type = ValueTypeValidator::VALUE_TYPE_VALUE
    email_elem = inbound_emails(:nick_n_xxx_y_yyy_n_tags_y_currency_sender_idable_inbound_email)
    # Set the path so that the "from:" email is used
    # otherwise sender is anonymous
    Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:send contract email for two mir with valid emails:#{logtag}, sess.request.inspect:#{sess.request.inspect}")
    sess.post_via_redirect "/inbound_emails_200", email_elem.attributes
    input_str = email_elem.subject
    input_str ||= email_elem.body_text
    input_str_hash = ControllerHelper.parse_meant_it_input(input_str)
    pii_str = input_str_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    pii = setup_pps_by_pii_value(pii_str, pps_currency, pps_threshold, pps_threshold_type,  pps_status, value_type, logtag=nil)
    # Send two emails to create two mirs associate with the pii
    email_elem1 = email_elem.dup
    pii_value, email_elem1_curr_val = change_value(email_elem1, 10)
    email_elem2 = email_elem.dup
    pii_value, email_elem2_curr_val = change_value(email_elem2, 10)
p "!!!!!!email_elem1_curr_val:#{email_elem1_curr_val}, email_elem2_curr_val:#{email_elem2_curr_val}"
    sess.post_via_redirect "/inbound_emails_200", email_elem1.attributes
    sess.post_via_redirect "/inbound_emails_200", email_elem2.attributes
    pii.reload
    # Check email_bill_entries, mirs, etc.
    assert(pii_value, pii_str)
    assert(1, pii.pii_property_set.email_bill_entries.size)
    assert(2, pii.pii_property_set.email_bill_entries[0].meant_it_rels.size)
    assert(1600, pii.pii_property_set.email_bill_entries[0].qty)
    assert(pps_currency, pii.pii_property_set.email_bill_entries[0].currency)
    first_bill = pii.pii_property_set.email_bill_entries[0]
    assert_not_nil(first_bill.ready_date)
    assert_nil(first_bill.billed_date)
    # Now simulate clicking on Contact
  end # end  test "send contract email for two mir with valid emails" do
end
