require 'controller_helper'

class PiisController < ApplicationController
#  before_filter :authorize, :except => [:index, :show, :create, :show_by_pii_value ]
  before_filter :authorize, :except => [:create, :show_by_pii_value, :show_by_message_type_uniq_sender_count, :show_like_pii_value_uniq_sender_count_after_last_bill ]

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
      format.html { render "show_pii_details", :layout => "find_any", :locals => { :find_any_input => decoded_pii_input } }
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

  def show_like_pii_value_uniq_sender_count_after_last_bill
    logtag = ControllerHelper.gen_logtag
    logger.info("#{File.basename(__FILE__)}:#{self.class}:show_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, params.inspect:#{params.inspect}")
    pii_value = params[Constants::PII_VALUE_INPUT]
    @pii = ControllerHelper.find_like_pii_value_uniq_sender_count_after_last_bill(pii_value, logtag)
    add_virtual_methods_to_pii(@pii[0], pii_value)
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, @pii.inspect:#{@pii.inspect}")
    if @pii.nil? or @pii.empty?
      pii = Pii.find_by_pii_value(pii_value)
      pps = pii.pii_property_set
      made_mir_count = nil
      if pps.threshold_type == PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_ONETIME and pps.status == StatusTypeValidator::STATUS_INACTIVE
        made_mir_count = pps.threshold
      else
        made_mir_count = 0
      end # end if pps.threshold_type == PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_ONETIME
      made_pii = [:pii => { :pii_value => pii_value, :threshold => pps.threshold, :mir_count => made_mir_count }]
      logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, made_pii.inspect:#{made_pii.inspect}")
      pii_to_json = made_pii.to_json
    else
      pii_to_json = @pii.to_json(:methods => [:threshold, :formula, :short_desc_data, :long_desc_data, :thumbnail_url_data, :thumbnail_qr_data])
    end # end if pii_to_json.nil? or pii_to_json.empty?
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, pii_to_json:#{pii_to_json}")

    respond_to do |format|
#      format.html { render "show_pii_details", :layout => "find_any", :locals => { :find_any_input => find_any_input } }
      format.xml  { render :xml => @pii }
      format.json { render :json => pii_to_json }
    end
  end # end def show_like_pii_value_uniq_sender_count_after_last_bill

  def show_by_message_type_uniq_sender_count
    logtag = ControllerHelper.gen_logtag
    logger.info("#{File.basename(__FILE__)}:#{self.class}:show_by_message_type_uniq_sender_count:#{logtag}, params.inspect:#{params.inspect}")
    order = params[Constants::COUNT_ORDER_INPUT]
    rec_limit = params[Constants::REC_LIMIT_INPUT]
    message_type = params[Constants::MESSAGE_TYPE_INPUT]
    pii_value = params[Constants::PII_VALUE_INPUT]
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_by_message_type_uniq_sender_count:#{logtag}, message_type:#{message_type}, pii_value:#{pii_value}")
    @pii = ControllerHelper.find_pii_by_message_type_uniq_sender_count(pii_value, message_type, rec_limit, order)
    @pii.each { |pii_elem|
    # NOTE: We cannot just use pii_elem.pii_property_set because it
    # is nil since the @pii is only has fields that we selected using
    # the options has that we feed into Pii.find
    # NOTE: We also couldn't find (after some search) to include fields
    # such as property_pii_set.pii_id into the options and if you think
    # about it maybe we shouldn't since everything returned is suppose
    # to be pii thus, the mashing together should be done here?
    # NOTE: We didn't use as_json in the pii class since we may not
    # always want those pii_property_set value attached.  Therefore
    # we use some metaprogramming to only include those values for this
    # pii.
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_by_message_type_uniq_sender_count:#{logtag}, pii_elem.inspect:#{pii_elem.inspect}")
    add_virtual_methods_to_pii(pii_elem, pii_value)

#        def as_json(options={})
#          super(
#            :methods => %w{:short_desc_data :long_desc_data :thumbnail_url_data }
#          )
#        end 
      logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_by_message_type_uniq_sender_count:#{logtag}, pii_elem.short_desc_data:#{pii_elem.short_desc_data}")
    }
    pii_to_json = @pii.to_json(:methods => [:threshold, :formula, :short_desc_data, :long_desc_data, :thumbnail_url_data, :thumbnail_qr_data])
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_by_message_type_uniq_sender_count:#{logtag}, pii_to_json:#{pii_to_json}")

    respond_to do |format|
#      format.html { render "show_pii_details", :layout => "find_any", :locals => { :find_any_input => find_any_input } }
      format.xml  { render :xml => @pii }
      format.json { render :json => pii_to_json }
    end
#      format.html { render "show_meant_it_rels_with_details", :layout => "find_any", :locals => { :meantItRels => meantItRels, :find_any_input => find_any_input_str, :title_str => title_str, :down_url => down_url, :up_url => up_url }  }
#      format.xml  { render :xml => meantItRels }
  end # end def show_by_message_type_uniq_sender_count

  private
    def add_virtual_methods_to_pii(pii_elem, pii_value)
      class << pii_elem
        def get_property_set_model
          pii_id = Pii.find_by_pii_value(pii_value)
          pii_property_set_model = PiiPropertySet.find_by_pii_id(pii_id)
          pii_property_set_model
        end

        def threshold
          @pii_property_set_model ||= get_property_set_model
          return_value = nil
          return_value = @pii_property_set_model.threshold if !@pii_property_set_model.nil?
          return_value
        end

        def formula
          @pii_property_set_model ||= get_property_set_model
          return_value = nil
          return_value = @pii_property_set_model.formula if !@pii_property_set_model.nil?
          return_value
        end

        def short_desc_data
          @pii_property_set_model ||= get_property_set_model
          return_value = nil
          return_value = @pii_property_set_model.short_desc if !@pii_property_set_model.nil?
          return_value
        end

        def long_desc_data
          @pii_property_set_model ||= get_property_set_model
          return_value = nil
          return_value = @pii_property_set_model.long_desc if !@pii_property_set_model.nil?
          return_value
        end

        def thumbnail_url_data
          @pii_property_set_model ||= get_property_set_model
          return_value = nil
          return_value = @pii_property_set_model.avatar.url(:thumb) if !@pii_property_set_model.nil?
          return_value
        end

        def thumbnail_qr_data
          @pii_property_set_model ||= get_property_set_model
          return_value = nil
          return_value = @pii_property_set_model.qr.url(:thumb) if !@pii_property_set_model.nil?
          return_value
        end
     end # end class << pii_elem
    end # end def add_virtual_methods_to_pii
end
