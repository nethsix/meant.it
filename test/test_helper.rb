ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # Runs assert_difference with a number of conditions and varying difference
  # counts.
  #
  # Call as follows:
  #
  # assert_differences([['Model1.count', 2], ['Model2.count', 3]])

  def assert_differences(expression_array, message = nil, &block)
    b = block.send(:binding)
    before = expression_array.map { |expr| eval(expr[0], b) }

    yield

    expression_array.each_with_index do |pair, i|
      e = pair[0]
      difference = pair[1]
      error = "#{e.inspect} didn't change by #{difference}"
      error = "#{message}\n#{error}" if message
      assert_equal(before[i] + difference, eval(e, b), error)
    end
  end

  # Create and set pii_property_set for give pii_value.
  # This is a convenience method that mere calls
  # +setup_pps_by_pii+
  # +:pii:+:: pii object
  # +:pps_currency:+:: currency in pii_property_set created
  # +:pps_threshold:+:: threshold in pii_property_set created
  # +:pps_threshold_type:+:: threshold_type in pii_property_set created
  # +:pps_status:+:: status of pii_property_set created
  # +:pps_value_type:+:: value_type in pii_property_set created
  # +:pps_notify:+:: value_type in pii_property_set created
  # Return +Pii+
  def setup_pps_by_pii_value(pii_value, pps_currency, pps_threshold, pps_threshold_type,  pps_status, pps_value_type, pps_notify=nil, logtag=nil)
    pii = Pii.find_by_pii_value(pii_value)
    setup_pps_by_pii(pii, pps_currency, pps_threshold, pps_threshold_type,  pps_status, pps_value_type, pps_notify, logtag)
    pii
  end # end def setup_pps_by_pii_value
    
  # Create and set pii_property_set for give pii
  # +:pii:+:: pii object
  # +:pps_currency:+:: currency in pii_property_set created
  # +:pps_threshold:+:: threshold in pii_property_set created
  # +:pps_threshold_type:+:: threshold_type in pii_property_set created
  # +:pps_status:+:: status of pii_property_set created
  # +:pps_value_type:+:: value_type in pii_property_set created
  # +:pps_notify:+:: value_type in pii_property_set created
  # Return +Pii+
  def setup_pps_by_pii(pii, pps_currency, pps_threshold, pps_threshold_type,  pps_status, pps_value_type, pps_notify=nil, logtag=nil)
    pii.pii_property_set = PiiPropertySet.create
    pii.pii_property_set.threshold = pps_threshold
    pii.pii_property_set.currency = pps_currency
    pii.pii_property_set.status = StatusTypeValidator::STATUS_ACTIVE
    pii.pii_property_set.value_type = pps_value_type
    pii.pii_property_set.threshold_type = pps_threshold_type
    pii.pii_property_set.notify = pps_notify if !pps_notify.nil?
    unless pii.pii_property_set.save
      Rails.logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:setup_pps_by_pii:#{logtag}, save error, pii.property_set.errors.inspect:#{pii.property_set.errors.inspect}")
      raise Exception, "#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:setup_pps_by_pii:#{logtag}, save error, pii.property_set.errors.inspect:#{pii.property_set.errors.inspect}"
    end # end unless pii.pii_property_set.save
    pii.reload
  end # end def setup_pps_by_pii

  # Get the first value in inbound_email input_str which is in subject/body
  # and return a new input_str consisting only +pii_value+ and the value added
  # with a specified +delta_value+
  # +:email_elem:+:: email_elem from inbound_email.yml fixtures
  # +:delta_value:+:: the value to change, which can be positive or negative
  # Return [+pii_value+, new value] and 
  # changes +email_elem.body_text+ or +email_elem.subject+
  # depending on where it found string to change
  def change_value(email_elem, delta_value, logtag=nil)
    input_str_in_subject = true
    input_str = email_elem.subject
    if input_str.nil?
      input_str = email_elem.body_text
      input_str_in_subject = false
    end # end if input_str.nil?
    # Get pii and currency
    input_str_hash = ControllerHelper.parse_meant_it_input(input_str)
    pii_str = input_str_hash[ControllerHelper::MEANT_IT_INPUT_RECEIVER_PII]
    curr_arr = ControllerHelper.get_currency_arr_from_str(input_str)
    # Just take one value
    prev_curr_curr_code, prev_curr_curr_val = ControllerHelper.get_currency_code_and_val(curr_arr[0])
    second_email_curr_code = prev_curr_curr_code
    second_email_curr_val = prev_curr_curr_val.to_f + delta_value.to_f
    second_email_curr_str = "#{second_email_curr_code}#{second_email_curr_val}"
    new_input_str = ":#{pii_str} #{second_email_curr_str}"
    if input_str_in_subject
      email_elem.subect = new_input_str
    else
      email_elem.body_text = new_input_str
    end # end if input_str_in_subject
    [pii_str, second_email_curr_val]
  end # end def change_value

  # Send meant.it email to a particular pii
  # +:email_elem:+:: email_elem from inbound_email.yml fixtures
  # OBSOLETE: Left here as a lesson!!!
  # Doing this will not work since we expect it to be called only
  # for inbound_email_controller functional test but
  # if called by others, then it will post to the callers controller, e.g.,
  # if sessions_controller_test.rb calls this then the post is directed
  # to sessions_controller#create which is not what we want
#20111204ERR  def send_meant_it(email_elem, logtag=nil)
#20111204ERR    @request.path = Constants::SENDGRID_PARSE_URL
#20111204ERR    post :create, :inbound_email => email_elem.attributes
#20111204ERR  end # end def send_meant_it

  # Create a session by login
  # Used in integration tests
#20111205 +path+ will always be nil if we open_session here
#20111205 We need do open_session in integration test method itself
#20111205ERR
  def login(username, password)
    open_session do |sess|
# If we want to emulate https
#      sess.https!
      sess.post_via_redirect "/sessions", "session[login_name]" => username, "session[password]" => password
      assert_equal '/', sess.path
      assert_equal Constants::LOGGED_IN_NOTICE, sess.flash[:notice]
# Unemulate https
#      sess.https!(false)
    end
  end # end def login

  # Run this to add Capybara common selectors
  def capybara_common_selectors
    Capybara.add_selector(:row) do
      xpath { |num| ".//tbody/tr[#{num}]" }
    end
    # NOTE: :row_col must be used in 'within(:row, num) do'
    Capybara.add_selector(:row_col) do
      xpath { |num| "./td[#{num}]" }
    end
  end # end def capybara_common_selectors
end
