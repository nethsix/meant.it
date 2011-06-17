require 'validators'

class Entity < ActiveRecord::Base

  validates :doc_id, :presence => true, :uniqueness => true
  validates :status, :presence => true, :status_type => true
  before_create :validate_status

  protected

  COUCHDB_ADDR = '127.0.0.1'
  COUCHDB_PORT = 5984
  COUCHDB_ENTITY_PROPERTIES = 'meant_it'

  def validate_status
#    errors.add(:status, "permits only active, inactive, deleted") if STATUS_ENUM.index(self.status.downcase).nil?
    if errors.empty?
      # Ensure that doc_id points to a valid doc in couchdb
      @conn ||= CouchRest.new("#{COUCHDB_ADDR}:#{COUCHDB_PORT}")
      @db ||= @conn.database(COUCHDB_ENTITY_PROPERTIES)
      begin
        couchdb_doc = @db.get(self.doc_id)
      rescue Exception => e
        errors.add(:doc_id, "does not point to a valid doc in couchdb") if couchdb_doc.nil?
      end # end @db.get ...
    end # end if errors.empty?
    errors.empty?
  end # end def validate_status
end
