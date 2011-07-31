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
  validates :uniq_id, :uniqueness => true, :allow_nil => true
end
