require 'constants'
class ShopsController < ApplicationController
  def show
    @entity = Entity.find(params[:id])
  end # end def show
end # end class ShopsController < ApplicationController
