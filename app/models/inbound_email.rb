require 'validators'

class InboundEmail < ActiveRecord::Base
  validates :headers, :presence => true
  validates :from, :presence => true
  validates :to, :presence => true
  validates :envelope, :presence => true
  validates :attachment_count, :presence => true
 
  validates_with BodyOrSubjectNotNullValidator
end
