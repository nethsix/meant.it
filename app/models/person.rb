class Person < CouchRest::Model::Base
  property :name
  property :email
  timestamps!
end
