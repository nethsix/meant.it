require 'validators'

class ObjRel < ActiveRecord::Base
  belongs_to :srcObj, :polymorphic => true
  belongs_to :dstObj, :polymorphic => true

  validates :relType, :presence => true, :obj_rel_type => true
  validates :status, :presence => true, :status_type => true
  validates :srcObj_id, :presence => true, :uniqueness => {:scope => [:dstObj_id, :relType] }
end
