require 'validators'

class ObjRel < ActiveRecord::Base
#  belongs_to :srcObj, :polymorphic => true
  belongs_to :srcobj, :polymorphic => true
#  belongs_to :dstObj, :polymorphic => true
  belongs_to :dstobj, :polymorphic => true

#  validates :relType, :presence => true, :obj_rel_type => true
  validates :rel_type, :presence => true, :obj_rel_type => true
#  validates :relObjType, :presence => true, :obj_rel_obj_type => true
  validates :rel_obj_type, :presence => true, :obj_rel_obj_type => true
  validates :status, :presence => true, :status_type => true
#  validates :srcObj_id, :presence => true, :uniqueness => {:scope => [:dstObj_id, :relType] }
  validates :srcobj_id, :presence => true, :uniqueness => {:scope => [:dstobj_id, :rel_type] }

  after_initialize :default_values

  private
    def default_values
      self.status||= "active"
    end
end
