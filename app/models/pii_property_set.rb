require 'validators'
class PiiPropertySet < ActiveRecord::Base
  has_attached_file :avatar, 
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
  validates :status, :presence => true, :liker_status_type => true

  after_initialize :default_values

  def last_bill_date
    last_bill_date_value = nil
    if !email_bill_entries.nil? and !email_bill_entries.empty?
      sorted_email_bill_entries = email_bill_entries.sort { |elem1, elem2|
        elem2.created_at <=> elem1.created_at
      } # end email_bill_entries.sort
      last_bill_date_value = sorted_email_bill_entries[0].created_at
    end # end if !email_bill_entries.nil? and !email_bill_entries.empty?
    last_bill_date_value
  end # end def self.last_bill_date

  private
    def default_values
      self.status||= StatusTypeValidator::STATUS_ACTIVE
      self.threshold_type ||= PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_ONETIME
    end
end
