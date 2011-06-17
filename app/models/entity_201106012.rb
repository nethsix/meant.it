require 'validators'

class Entity < ActiveRecord::Base

  validates :doc_id, :presence => true, :uniqueness => true, :doc_id_foreign_key => true
  validates :status, :presence => true, :status_type => true

end
