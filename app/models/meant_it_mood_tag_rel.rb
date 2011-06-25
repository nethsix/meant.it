require 'validators'

class MeantItMoodTagRel < ActiveRecord::Base
  MOOD_TAG_TYPE = "mood"
  belongs_to :meantItRel
  belongs_to :tag
  validates :reasoner, :presence => true, :mood_reasoner => true
  validates :status, :presence => true, :status_type => true

  after_initialize :default_values

  private
    def default_values
      self.status ||= StatusTypeValidator::STATUS_ACTIVE
      self.reasoner ||= MoodReasonerValidator::MOOD_REASONER_DEFAULT
    end
end
