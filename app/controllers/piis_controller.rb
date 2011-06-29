require 'controller_helper'

class PiisController < ApplicationController
  # GET /piis
  # GET /piis.xml
  def index
    @piis = Pii.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @piis }
    end
  end

  # GET /piis/1
  # GET /piis/1.xml
  def show
    @pii = Pii.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pii }
    end
  end

  # GET /piis/new
  # GET /piis/new.xml
  def new
    @pii = Pii.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pii }
    end
  end

  # GET /piis/1/edit
  def edit
    @pii = Pii.find(params[:id])
  end

  # POST /piis
  # POST /piis.xml
  def create
    @pii = Pii.new(params[:pii])

    respond_to do |format|
      if @pii.save
        format.html { redirect_to(@pii, :notice => 'Pii was successfully created.') }
        format.xml  { render :xml => @pii, :status => :created, :location => @pii }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pii.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /piis/1
  # PUT /piis/1.xml
  def update
    @pii = Pii.find(params[:id])

    respond_to do |format|
      if @pii.update_attributes(params[:pii])
        format.html { redirect_to(@pii, :notice => 'Pii was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pii.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /piis/1
  # DELETE /piis/1.xml
  def destroy
    @pii = Pii.find(params[:id])
    @pii.destroy

    respond_to do |format|
      format.html { redirect_to(piis_url) }
      format.xml  { head :ok }
    end
  end

  def find_by_pii_value
    respond_to do |format|
      format.html # find_by_pii_value.html.erb
      format.xml  { render :xml => @pii }
    end
  end

  def find_by_pii_value_debug
    respond_to do |format|
      format.html # find_by_pii_value_debug.html.erb
      format.xml  { render :xml => @pii }
    end
  end

  def show_by_pii_value
    logtag = ControllerHelper.gen_logtag
    logger.info("#{File.basename(__FILE__)}:#{self.class}:show_by_pii_value:#{logtag}, params[Constants::PII_VALUE_INPUT]:#{params[Constants::PII_VALUE_INPUT]}")
    pii_value_input = params[Constants::PII_VALUE_INPUT]
    decoded_pii_input = URI::decode(pii_value_input)
    decoded_pii_input.chomp!
    decoded_pii_input.strip!
    @pii = nil
    @pii = Pii.find_by_pii_value(decoded_pii_input) if !decoded_pii_input.nil?
    logger.info("#{File.basename(__FILE__)}:#{self.class}:show_by_pii_value:#{logtag}, @pii:#{@pii.inspect}")

    respond_to do |format|
      format.html { render "show_pii_details" }
      format.xml  { render :xml => @pii }
    end
  end

  def show_by_pii_value_debug
    logtag = ControllerHelper.gen_logtag
    logger.info("#{File.basename(__FILE__)}:#{self.class}:show_by_pii_value_debug:#{logtag}, params[Constants::PII_VALUE_INPUT]:#{params[Constants::PII_VALUE_INPUT]}")
    pii_value_input = params[Constants::PII_VALUE_INPUT]
    decoded_pii_input = URI::decode(pii_value_input)
    decoded_pii_input.chomp!
    decoded_pii_input.strip!
    @pii = nil
    @pii = Pii.find_by_pii_value(decoded_pii_input) if !decoded_pii_input.nil?
    logger.info("#{File.basename(__FILE__)}:#{self.class}:show_by_pii_value_debug:#{logtag}, @pii:#{@pii.inspect}")

    respond_to do |format|
      format.html { render "show_pii_details_debug" }
      format.xml  { render :xml => @pii }
    end
  end
end
