class Constants
  EMAIL_COST = 0.1
  DEFAULT_CURRENCY = "USD"
  CURRENCY_REGEX1 = "[A-Za-z]{3}"
  CURREG1 = CURRENCY_REGEX1
  CURRENCY_REGEX2 = "\\d+\\.*\\d*"
  CURREG2 = CURRENCY_REGEX2

  # Contract/Payment parms
  SHA1_LEN = 48
  CONTRACT_NO_LEN = 8 # in chars
  CONTRACT_DELIM = '-'

  TITLE_STR = "title_str"
  EMAIL_VALUE_INPUT = "email"
  PII_VALUE_INPUT = "pii_value_input"
  BILL_ENTRY_ID_VALUE_INPUT = "bill_entry_id_value_input"
  MESSAGE_TYPE_INPUT= "message_type_input"
  FIND_ANY_INPUT = "find_any_input"
  TAGS_INPUT = "tags_input"
  CLAIM_INPUT = "claim_input"
  END_POINT_NICK_INPUT = "end_point_nick_input"
  END_POINT_CREATOR_END_POINT_INPUT = "end_point_creator_end_point_input"
  MEANT_IT_REL_PAGE_SIZE = "pg_size"
  MEANT_IT_REL_LAST_ID = "last_id"
  MEANT_IT_REL_START_ID = "start_id"
  REC_LIMIT_INPUT = "rec_limit"
  COUNT_ORDER_INPUT = "count_order"
  SQL_COUNT_ORDER_ASC = "asc"
  SQL_COUNT_ORDER_DESC = "desc"
  SORT_FIELD_INPUT = "sort_field"
  SORT_ORDER_INPUT = "sort_order"

  PAGINATE_BATCH_SIZE = 5
  MIN_PASSWORD_LEN = 6

  ENTITY_DOMAIN_MARKER = "==="

  MEANT_IT_PII_SUFFIX = "@pii.meant.it"
  SENDGRID_SMTP_WHITELIST = []
  TEST_SMTP_WHITELIST = ['127.0.0.1']

  SENDGRID_PARSE_URL = "/inbound_emails_200"

  SESSION_CONFIRM_EMAIL_ENDPOINT_ID = :session_confirm_email_endpoint_id
  SESSION_ENTITY_ID = :session_entity_id
#20111023SOLN#2  REDIRECT_URL = :redirect_url

  WEB_MAX_MEANTIT_IN = 3
  WEB_MAX_MEANTIT_OUT = 3
  WEB_MAIN_MAX_MEANTIT = 5
  WEB_PAGE_RESULT_SIZE = 10

  LIKEBOARD_REC_LIMIT = 10

  MEANT_IT_RELS_DETAILS_SRC = :src
  MEANT_IT_RELS_DETAILS_DST = :dst

  WHY_ENUM = [ 
    ["A voice for you and me", "If enough people share the same voice, we can bring change"],
    ["A rendezvous", "A place to wait for someone who threw you a smile"],
    ["Communicate anonymously", "Avoid awkward moments; hint something to help someone change"],
    ["Better than disinterested thank you emails", "Each Meant.It builds the receiver's global reputation"],
    ["Portable reputation", "Reputation that follows even when you relocate, switch jobs, etc."],
    ["Declare a found item", "Returning lost item makes the owner's day; who knows what awaits you"],
  ]
  MEANT_IT_GENERAL = ["Tracked public/private communication between end points", "Use it however you want"]
  def self.random_why
    why_str = WHY_ENUM[rand(WHY_ENUM.size)]
  end # end def random_why
end # end class Constants
