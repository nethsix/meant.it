require 'constants'
class ShopsController < ApplicationController
  SORT_FIELD_DATE = "date"
  SORT_FIELD_PRICE = "price"
  SORT_FIELD_GROUP_SIZE = "gsize"
  SORT_FIELD_NEAR_GOAL = "ng"
  SORT_FIELD_BEST_SELL = "bestsell"
  SORT_FIELD_ENUM = [ SORT_FIELD_DATE, SORT_FIELD_PRICE, SORT_FIELD_GROUP_SIZE, SORT_FIELD_NEAR_GOAL, SORT_FIELD_BEST_SELL ]
  SORT_ORDER_ASC = "asc"
  SORT_ORDER_DESC = "desc"
  SORT_ORDER_ENUM = [ SORT_ORDER_ASC, SORT_ORDER_DESC ]
  def show
    @entity = Entity.find(params[:id])
    @sort_order = params[Constants::SORT_ORDER_INPUT]
    @sort_field = params[Constants::SORT_FIELD_INPUT]
  end # end def show
end # end class ShopsController < ApplicationController
