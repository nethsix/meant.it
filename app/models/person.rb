class Person < CouchRest::Model::Base
  property :name, :presence => true
  property :email, :presence => true  # This doesn't seem to work, :uniqueness => true
  timestamps!

  validates_uniqueness_of :email
end
