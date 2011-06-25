require 'validators'

class MeantItMoodTagRel < ActiveRecord::Base
  belongs_to :tag
  belongs_to :meant_it_rel
  validates :reasoner, :presence => true, :mood_reasoner => true
  validates :status, :presence => true, :status_type => true

  after_initialize :default_values

  private
    def default_values
      self.status ||= StatusTypeValidator::STATUS_ACTIVE
      self.reasoner ||= MoodReasonerValidator::MOOD_REASONER_DEFAULT
    end
end
