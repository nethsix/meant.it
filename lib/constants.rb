class Constants
  TITLE_STR = "title_str"
  PII_VALUE_INPUT = "pii_value_input"
  MESSAGE_TYPE_INPUT= "message_type_input"
  FIND_ANY_INPUT = "find_any_input"
  TAGS_INPUT = "tags_input"
  END_POINT_NICK_INPUT = "end_point_nick_input"
  END_POINT_CREATOR_END_POINT_INPUT = "end_point_creator_end_point_input"

  MEANT_IT_PII_SUFFIX = "@pii.meant.it"

  WEB_MAX_MEANTIT_IN = 1
  WEB_MAX_MEANTIT_OUT = 1

  MEANT_IT_RELS_DETAILS_SRC = :src
  MEANT_IT_RELS_DETAILS_DST = :dst

  WHY_ENUM = [ 
    ["Better than disinterested thank you emails", "Each Meant.It builds the receiver's global reputation"],
    ["Portable reputation", "Reputation that follows even when you relocate, switch jobs, etc."],
    ["Declare a found item", "Returning lost item makes the owner's day; besides good karma, who knows what awaits you"],
    ["Communicate anonymously", "Avoid awkward moments; hint at something and help someone change for the better"],
    ["A voice for you and me", "If enough people share the same voice, we can bring change"],
    ["A rendezvous", "A location to meet with someone who met eyes with you"]
  ]
  MEANT_IT_GENERAL = ["Tracked communication between end points", "Your imagatination determines what it can be used for"]
  def self.random_why
    why_str = WHY_ENUM[rand(WHY_ENUM.size)]
  end # end def random_why
end # end class Constants
