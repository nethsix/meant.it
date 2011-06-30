require 'controller_helper'
require 'constants'

class EndPointsController < ApplicationController
  # GET /end_points
  # GET /end_points.xml
  def index
    @end_points = EndPoint.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @end_points }
    end
  end

  # GET /end_points/1
  # GET /end_points/1.xml
  def show
    @end_point = EndPoint.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @end_point }
    end
  end

  # GET /end_points/new
  # GET /end_points/new.xml
  def new
    @end_point = EndPoint.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @end_point }
    end
  end

  # GET /end_points/1/edit
  def edit
    @end_point = EndPoint.find(params[:id])
  end

  # POST /end_points
  # POST /end_points.xml
  def create
    @end_point = EndPoint.new(params[:end_point])

    respond_to do |format|
      if @end_point.save
        format.html { redirect_to(@end_point, :notice => 'End point was successfully created.') }
        format.xml  { render :xml => @end_point, :status => :created, :location => @end_point }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @end_point.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /end_points/1
  # PUT /end_points/1.xml
  def update
    @end_point = EndPoint.find(params[:id])

    respond_to do |format|
      if @end_point.update_attributes(params[:end_point])
        format.html { redirect_to(@end_point, :notice => 'End point was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @end_point.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /end_points/1
  # DELETE /end_points/1.xml
  def destroy
    @end_point = EndPoint.find(params[:id])
    @end_point.destroy

    respond_to do |format|
      format.html { redirect_to(end_points_url) }
      format.xml  { head :ok }
    end
  end

  def show_by_nick
    logtag = ControllerHelper.gen_logtag
    end_point_nick = params[:nick]
    logger.info("#{File.basename(__FILE__)}:#{self.class}:show_by_nick:#{logtag}, end_point_nick:#{end_point_nick}")
    decoded_end_point_nick_input = URI::decode(end_point_nick)
    decoded_end_point_nick_input.chomp!
    decoded_end_point_nick_input.strip!
    logger.info("#{File.basename(__FILE__)}:#{self.class}:show_by_nick:#{logtag}, decoded_end_point_nick_input:#{decoded_end_point_nick_input}")
    @endPoint_arr = EndPoint.where("nick = ?", decoded_end_point_nick_input)

    respond_to do |format|
      format.html { render "show_end_points" }
      format.xml  { render :xml => @endPoint_arr }
    end
  end # end def show_by_nick

  def show_by_id
    logtag = ControllerHelper.gen_logtag
    @endPoint = EndPoint.find(params[:id])
    logger.info("#{File.basename(__FILE__)}:#{self.class}:show_by_id:#{logtag}, @endPoint:#{@endPoint.inspect}")

    respond_to do |format|
      format.html { render "show_end_point_details" }
      format.xml  { render :xml => @endPoint }
    end
  end # end def show_by_id

  def show_by_nick_and_creator_endpoint_id
    logtag = ControllerHelper.gen_logtag
    logger.info("#{File.basename(__FILE__)}:#{self.class}:show_by_nick_and_creator_endpoint_id:#{logtag}, params[Constants::END_POINT_NICK_INPUT]:#{params[Constants::END_POINT_NICK_INPUT]}")
    end_point_nick = params[Constants::END_POINT_NICK_INPUT]
    decoded_end_point_nick_input = URI::decode(end_point_nick)
    decoded_end_point_nick_input.chomp!
    decoded_end_point_nick_input.strip!
    logger.info("#{File.basename(__FILE__)}:#{self.class}:show_by_nick_and_creator_endpoint_id:#{logtag}, params[Constants::END_POINT_CREATOR_END_POINT_INPUT]:#{params[Constants::END_POINT_CREATOR_END_POINT_INPUT]}")
    end_point_creator_end_point = params[Constants::END_POINT_CREATOR_END_POINT_INPUT]
    end_point_creator_end_point_id = end_point_creator_end_point.to_i 
    @endPoint = nil
    @endPoint = EndPoint.find_by_nick_and_creator_endpoint_id(decoded_end_point_nick_input, end_point_creator_end_point_id) if !decoded_end_point_nick_input.nil? and !end_point_creator_end_point_id.nil?
    logger.info("#{File.basename(__FILE__)}:#{self.class}:show_by_nick_and_creator_endpoint_id:#{logtag}, @endPoint:#{@endPoint.inspect}")

    respond_to do |format|
      format.html { render "show_end_point_details" }
      format.xml  { render :xml => @endPoint }
    end
  end

  def show_by_tags
    logtag = ControllerHelper.gen_logtag
    logger.info("#{File.basename(__FILE__)}:#{self.class}:show_by_tags:#{logtag}, params[Constants::TAGS_INPUT]:#{params[Constants::TAGS_INPUT]}")
    tags_input = params[Constants::TAGS_INPUT]
    decoded_tags_input = URI::decode(tags_input)
    decoded_tags_input.chomp!
    decoded_tags_input.strip!
    decoded_tags_arr = decoded_tags_input.split if !decoded_tags_input.nil?
    @endPoint_arr = nil
    @endPoint_arr = EndPoint.tagged(decoded_tags_arr) if !decoded_tags_input.nil?
    logger.info("#{File.basename(__FILE__)}:#{self.class}:show_by_tags:#{logtag}, @endPoint_arr:#{@endPoint_arr.inspect}")

    respond_to do |format|
      format.html { render "show_end_points" }
      format.xml  { render :xml => @endPoint_arr }
    end
  end

  def find_by_tags
    respond_to do |format|
      format.html # find_by_tags.html.erb
      format.xml  { render :xml => @endPoint_arr }
    end
  end

  def find_by_nick_and_creator_endpoint_id
    respond_to do |format|
      format.html # find_by_nick_and_creator_endpoint_id.html.erb
      format.xml  { render :xml => @endPoint_arr }
    end
  end
end
