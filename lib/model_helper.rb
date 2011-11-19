# Base on: http://stackoverflow.com/questions/2328984/rails-extending-activerecordbase
module ModelHelper
  def self.included(base)
    base.extend(ClassMethods)
  end
 
  # Add instance methods here

  module ClassMethods
    def paginate_by_id(where_str, start_id_inclusive, page_size = Constants::WEB_PAGE_RESULT_SIZE, batch_size = Constants::PAGINATE_BATCH_SIZE, logtag = nil)
      total_size = 0
      start_idx = start_id_inclusive
      result_container = nil
#WHAT!?!?      end_id = self.all.size
      end_id = self.last.id
      end_id -= 1 if self::FIRST_INDEX == 0
      Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:paginate_by_id:#{logtag}, start_idx:#{start_idx}, end_id:#{end_id}")
      while total_size < page_size and start_idx <= end_id
        if where_str.nil?
          curr_res = self.where("id <= ? and id >= ?", start_idx+batch_size, start_idx)
        else
          curr_res = self.where("id <= ? and id >= ? and #{where_str}", start_idx+batch_size, start_idx)
        end # end if !where_str.nil?
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:paginate_by_id:#{logtag}, curr_res.inspect:#{curr_res.inspect}")
        if result_container.nil?
          result_container = curr_res
        else
          result_container += curr_res
        end # end if result_container.nil?
        curr_res = nil
        total_size = result_container.size
        start_idx = start_idx+batch_size
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:paginate_by_id:#{logtag}, start_idx:#{start_idx}, total_size:#{total_size}")
      end # end while ...
      result_container.sort! { |a,b| b.id <=> a.id }
      # Truncate result size to page_size
      return result_container[0,page_size]
#      return result_container
    end # end def paginate_by_id

    def reverse_paginate_by_id(where_str, last_id_inclusive, page_size = Constants::WEB_PAGE_RESULT_SIZE, batch_size = Constants::PAGINATE_BATCH_SIZE, logtag = nil)
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:reverse_paginate_by_id:#{logtag}, where_str:#{where_str}, page_size:#{page_size}, batch_size:#{batch_size}")
      total_size = 0
      last_idx = last_id_inclusive
      result_container = nil
      while total_size < page_size and last_idx >= self::FIRST_INDEX
        if where_str.nil?
          curr_res = self.where("id <= ? and id >= ?", last_idx, last_idx-batch_size)
        else
          curr_res = self.where("id <= ? and id >= ? and #{where_str}", last_idx, last_idx-batch_size)
        end # end if !where_str.nil?
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:reverse_paginate_by_id:#{logtag}, curr_res.inspect:#{curr_res.inspect}")
        if result_container.nil?
          result_container = curr_res
        else
          result_container += curr_res
        end # end if result_container.nil?
        curr_res = nil
        total_size = result_container.size
        last_idx = last_idx-batch_size
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:reverse_paginate_by_id:#{logtag}, last_idx:#{last_idx}, total_size:#{total_size}")
      end # end while ...
      result_container.sort! { |a,b| b.id <=> a.id }
      # Truncate result size to page_size
      return result_container[0,page_size]
#      return result_container
    end # end reverse_paginate_by_id

    def up_more(where_str, last_id, batch_size = Constants::PAGINATE_BATCH_SIZE, logtag = nil)
      last_idx = last_id
      total_size = self.last.id.to_i
      end_id = self::FIRST_INDEX == 0 ? total_size-1 : total_size
      next_found = false
      while (last_idx <= end_id and !next_found)
        if where_str.nil?
          curr_res = self.where("id <= ? and id > ?", last_idx+batch_size, last_idx) 
        else
          curr_res = self.where("id <= ? and id > ? and #{where_str}", last_idx+batch_size, last_idx)
        end # end if !where_str.nil?
        Rails.logger.debug("#{File.basename(__FILE__)}:#{self.class}:up_more:#{logtag}, last_idx:#{last_idx}, curr_res.inspect:#{curr_res.inspect}")
        next_found = true if !curr_res.nil? and curr_res.size > 0
        last_idx = last_idx+batch_size
      end # end while (last_idx <= end_id)
      next_found
    end # end def up_more

    def down_more(where_str, last_id, batch_size = Constants::PAGINATE_BATCH_SIZE , logtag = nil)
      last_idx = last_id
      end_id = self::FIRST_INDEX
      next_found = false
      while (last_idx >= end_id and !next_found)
        if where_str.nil?
          curr_res = self.where("id < ? and id >= ?", last_idx, last_idx-batch_size) 
        else
          curr_res = self.where("id < ? and id >= ? and #{where_str}", last_idx, last_idx-batch_size)
        end # end if !where_str.nil?
        next_found = true if !curr_res.nil? and curr_res.size > 0
        last_idx = last_idx-batch_size
      end # end while (last_idx >= end_id)
      next_found
    end # end def up_more
  end # end module ClassMethods
end # end module ModelHelper
ActiveRecord::Base.send(:include, ModelHelper)
