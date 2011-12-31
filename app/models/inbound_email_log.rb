class InboundEmailLog < ActiveRecord::Base
  serialize :params_txt
end
