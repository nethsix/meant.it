require 'validators'
class PiiPropertySet < ActiveRecord::Base
  # IMPT: formula field contains mix of positional and named parms
  # Thus far we use the first digit positional parm as price.
  # All parms are delimited by DELIM.
  # We can use the method +get_named_parm_from_formula+ in +ControllerHelper+
  # The following are name parms we are using
  # Refers to the full url of the item
  NAME_PARM_URL = 'url'

  DELIM = ";"
#20110813  include ActiveModel::Dirty

#20110813  define_attribute_methods  = [:status]

  has_attached_file :avatar, 
    :default_url => "/images/unknown.jpg",
    :path => ":hash.:extension", 
#    :styles => { :medium => "300x300>", :thumb => "100x100>" }
    :styles => { :medium => "300x300>", :thumb => "100x100>" },
    :hash_secret => "deer gloomy",
    :storage => :s3,
    :bucket => 'ncal-meantit',
    :s3_credentials => {
      :access_key_id => ENV['S3_KEY'],
      :secret_access_key => ENV['S3_SECRET']
    }

  has_attached_file :qr, 
    :default_url => "/images/no_qr.jpg",
    :path => ":hash.:extension", 
#    :styles => { :medium => "300x300>", :thumb => "100x100>" }
    :styles => { :medium => "300x300>", :thumb => "100x100>" },
    :hash_secret => "deer gloomy",
    :storage => :s3,
    :bucket => 'ncal-meantit',
    :s3_credentials => {
      :access_key_id => ENV['S3_KEY'],
      :secret_access_key => ENV['S3_SECRET']
    }

  belongs_to :pii
  has_many :email_bill_entries
  validates :uniq_id, :uniqueness => true, :allow_nil => true
  validates :threshold_type, :presence => true, :pii_property_set_threshold_type => true
  validates :status, :presence => true, :status_type => true
  validates :value_type, :presence => true, :value_type => true

  after_initialize :default_values
  before_save :before_save_stuff

#20110813  def status
#20110813   @status
#20110813  end

#20110813  def status=(val)
#20110813    status_will_change! unless val == @status
#20110813 p "valvalval:#{val}"
#20110813 p "@status:#{@status}"
#20110813    @active_date = Time.now if val == StatusTypeValidator::STATUS_ACTIVE
#20110813    @status = val
#20110813  end

#20110813  def save
#20110813 p "changes:#{changes}"
#20110813    @previously_changed = changes
#20110813    @changed_attributes.clear
#20110813  end


  # Default is the value given if nil otherwise, there'll be
  # error when we do <=>
  def last_bill(field_name, default_val = Time.parse("1700-01-01"))
    last_bill = nil
    if !email_bill_entries.nil? and !email_bill_entries.empty?
      sorted_email_bill_entries = email_bill_entries.sort { |elem1, elem2|
        # Example of block: elem2.created_at <=> elem1.created_at
        val1 = elem1.send(field_name)
        val1 ||= default_val
        val2 = elem2.send(field_name)
        val2 ||= default_val
        val2 <=> val1
      } # end email_bill_entries.sort
      last_bill = sorted_email_bill_entries[0]
    end # end if !email_bill_entries.nil? and !email_bill_entries.empty?
    last_bill
  end # end def last_bill

  private
    def before_save_stuff
p "self.status_was:#{self.status_was}"
p "self.status:#{self.status}"
      if self.status_was != StatusTypeValidator::STATUS_ACTIVE and self.status == StatusTypeValidator::STATUS_ACTIVE
        self.active_date = Time.now
      end # end f self.status == StatusTypeValidator::STATUS_ACTIVE
    end # end def before_save_stuff

    def default_values
      self.status ||= StatusTypeValidator::STATUS_INACTIVE
      self.threshold_type ||= PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_ONETIME
      self.active_date ||= Time.now
      self.value_type ||= ValueTypeValidator::VALUE_TYPE_COUNT_UNIQ
    end
end
