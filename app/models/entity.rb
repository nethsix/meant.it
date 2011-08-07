require 'validators'

class Entity < ActiveRecord::Base

  attr_accessor :password
#  attr_accessible :login_name, :password


  has_many :entityEndPointRels
  has_many :endPoints, :through => :entityEndPointRels
  has_one :email_bill

#  validates :propertyDocument_id, :presence => true, :uniqueness => true, :propertyDocument_id_foreign_key => true
#  validates :property_document_id, :uniqueness => true, :property_document_id_foreign_key => true
  validates :login_name, :presence => true, :uniqueness => true, :simple_name => true
  validates_presence_of :password, :on => :create
  validates :password, :length => { :minimum => Constants::MIN_PASSWORD_LEN }, :on => :create
  validates :status, :presence => true, :status_type => true

  after_initialize :default_values
  before_save :encrypt_password


  private
    def default_values
      self.status||= StatusTypeValidator::STATUS_ACTIVE
    end

    def encrypt_password
      logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:encrypt_password, password.present?:#{password.present?}")
      if password.present?
        self.password_salt = BCrypt::Engine.generate_salt  
        self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)  
      end  
    end 

    def self.authenticate(login_name, password)
      entity = Entity.find_by_login_name(login_name) if !login_name.nil?
      logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:authenticate, login_name:#{login_name}, entity.inspect:#{entity.inspect}")
      pass_hash = BCrypt::Engine.hash_secret(password, entity.password_salt) if !entity.nil?
      if entity && entity.password_hash == pass_hash
        entity
      elsif entity && entity.password_hash != pass_hash
        false
      else
        nil
      end # end if entity && ...
    end # end def self.authenticate

end
