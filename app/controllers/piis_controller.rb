require 'controller_helper'

class PiisController < ApplicationController
#  before_filter :authorize, :except => [:index, :show, :create, :show_by_pii_value ]
  before_filter :authorize, :except => [:create, :show_by_pii_value, :show_by_message_type_uniq_sender_count, :show_like_pii_value_uniq_sender_count_after_last_bill, :show_like_pii_value_non_uniq_sender_count_after_last_bill, :pii_property_set_limited ]

  # Create a limited pii_property_set since some information
  # is private
  def create_pps_limited(pii_value, pps, logtag=nil)
    new_pps = [:pii_property_set=> { pii_value => pii_value, :threshold => pps.threshold, :short_desc_data => pps.short_desc, :price => ControllerHelper.get_price_from_formula(pps.formula), :currency => ControllerHelper.get_currency_from_formula(pps.formula), :threshold_currency => pps.currency, :value_type => pps.value_type }]
    logger.info("#{File.basename(__FILE__)}:#{self.class}:create_pps_limited:#{logtag}, new_pps.inspect:#{new_pps.inspect}")
    new_pps
  end # end def create_pps_limited

  def pii_property_set_limited
    logtag = ControllerHelper.gen_logtag
    logger.info("#{File.basename(__FILE__)}:#{self.class}:pii_property_set_limited:#{logtag}, params.inspect:#{params.inspect}")
    pii_value = params[Constants::PII_VALUE_INPUT]
    pii = Pii.find_by_pii_value(pii_value)
    @pps = create_pps_limited(pii_value, pii.pii_property_set)
    respond_to do |format|
      format.json { render :json=> @pps }
      format.xml { render :xml=> @pps }
    end # end respond_to ...
  end # end def pii_property_set_limited

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
#20111103    @pii = ControllerHelper.find_like_pii_value_uniq_sender_count_after_last_bill(pii_value, logtag)
#20111103    add_virtual_methods_to_pii(@pii[0], pii_value)
#20111103    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, @pii.inspect:#{@pii.inspect}")
#20111103    if @pii.nil? or @pii.empty?
#20111103      pii = Pii.find_by_pii_value(pii_value)
#20111103      pps = pii.pii_property_set
#20111103      made_mir_count = nil
#20111103      if pps.threshold_type == PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_ONETIME and pps.status == StatusTypeValidator::STATUS_INACTIVE
#20111103        made_mir_count = pps.threshold
#20111103      else
#20111103        made_mir_count = 0
#20111103      end # end if pps.threshold_type == PiiPropertySetThresholdTypeValidator::THRESHOLD_TYPE_ONETIME
#20111103      made_pii = [:pii => { :pii_value => pii_value, :threshold => pps.threshold, :formula => pps.formula, :short_desc_data => pps.short_desc, :mir_count => made_mir_count, :thumbnail_url_data => pps.avatar.url(:thumb), :thumbnail_qr_data => pps.qr.url(:thumb), :threshold_type => pps.threshold_type }]
#20111103      logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, made_pii.inspect:#{made_pii.inspect}")
#20111103      pii_to_json = made_pii.to_json
#20111103    else
#20111103      pii_to_json = @pii.to_json(:methods => [:threshold, :formula, :short_desc_data, :long_desc_data, :thumbnail_url_data, :thumbnail_qr_data, :threshold_type])
#20111103    end # end if pii_to_json.nil? or pii_to_json.empty?
#20111212    pii_to_json = ControllerHelper.get_json_like_pii_value_uniq_sender_count_after_last_bill(pii_value, logtag)
#20111212 : Start
    old_ver = params[Constants::OLD_VERSION_INPUT] == "true" ? true : false
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, old_ver:#{old_ver}")
#20111212 : End
#20111227    pii_to_json = ControllerHelper.get_json_like_pii_value_uniq_sender_count_after_last_bill(pii_value, logtag, old_ver)
    pii_to_json = ControllerHelper.get_json_like_pii_value_sender_count_after_last_bill(pii_value, true, logtag, old_ver)
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, pii_to_json:#{pii_to_json}")

    respond_to do |format|
#      format.html { render "show_pii_details", :layout => "find_any", :locals => { :find_any_input => find_any_input } }
#20111103      format.xml  { render :xml => @pii }
      format.json { render :json => pii_to_json }
    end
  end # end def show_like_pii_value_uniq_sender_count_after_last_bill

  def show_like_pii_value_non_uniq_sender_count_after_last_bill
    logtag = ControllerHelper.gen_logtag
    logger.info("#{File.basename(__FILE__)}:#{self.class}:show_like_pii_value_non_uniq_sender_count_after_last_bill:#{logtag}, params.inspect:#{params.inspect}")
    pii_value = params[Constants::PII_VALUE_INPUT]
    old_ver = params[Constants::OLD_VERSION_INPUT] == "true" ? true : false
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_like_pii_value_uniq_sender_count_after_last_bill:#{logtag}, old_ver:#{old_ver}")
#20111227    pii_to_json = ControllerHelper.get_json_like_pii_value_uniq_sender_count_after_last_bill(pii_value, logtag, old_ver)
    pii_to_json = ControllerHelper.get_json_like_pii_value_sender_count_after_last_bill(pii_value, false, logtag, old_ver)
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_like_pii_value_non_uniq_sender_count_after_last_bill:#{logtag}, pii_to_json:#{pii_to_json}")

    respond_to do |format|
#      format.html { render "show_pii_details", :layout => "find_any", :locals => { :find_any_input => find_any_input } }
#20111103      format.xml  { render :xml => @pii }
      format.json { render :json => pii_to_json }
    end
  end # end def show_like_pii_value_non_uniq_sender_count_after_last_bill

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
    ControllerHelper.add_virtual_methods_to_pii(pii_elem, pii_value)

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

#20111103  private
#20111103    def add_virtual_methods_to_pii(pii_elem, pii_value)
#20111103      class << pii_elem
#20111103        def get_property_set_model
#20111103          pii_id = Pii.find_by_pii_value(pii_value)
#20111103          pii_property_set_model = PiiPropertySet.find_by_pii_id(pii_id)
#20111103          pii_property_set_model
#20111103        end
#20111103
#20111103        def threshold
#20111103          @pii_property_set_model ||= get_property_set_model
#20111103          return_value = nil
#20111103          return_value = @pii_property_set_model.threshold if !@pii_property_set_model.nil?
#20111103          return_value
#20111103        end
#20111103
#20111103        def formula
#20111103          @pii_property_set_model ||= get_property_set_model
#20111103          return_value = nil
#20111103          return_value = @pii_property_set_model.formula if !@pii_property_set_model.nil?
#20111103          return_value
#20111103        end
#20111103
#20111103        def short_desc_data
#20111103          @pii_property_set_model ||= get_property_set_model
#20111103          return_value = nil
#20111103          return_value = @pii_property_set_model.short_desc if !@pii_property_set_model.nil?
#20111103          return_value
#20111103        end
#20111103
#20111103        def long_desc_data
#20111103          @pii_property_set_model ||= get_property_set_model
#20111103          return_value = nil
#20111103          return_value = @pii_property_set_model.long_desc if !@pii_property_set_model.nil?
#20111103          return_value
#20111103        end
#20111103
#20111103        def thumbnail_url_data
#20111103          @pii_property_set_model ||= get_property_set_model
#20111103          return_value = nil
#20111103          return_value = @pii_property_set_model.avatar.url(:thumb) if !@pii_property_set_model.nil?
#20111103          return_value
#20111103        end
#20111103
#20111103        def thumbnail_qr_data
#20111103          @pii_property_set_model ||= get_property_set_model
#20111103          return_value = nil
#20111103          return_value = @pii_property_set_model.qr.url(:thumb) if !@pii_property_set_model.nil?
#20111103          return_value
#20111103        end
#20111103
#20111103        def threshold_type
#20111103          @pii_property_set_model ||= get_property_set_model
#20111103          return_value = nil
#20111103          return_value = @pii_property_set_model.threshold_type if !@pii_property_set_model.nil?
#20111103          return_value
#20111103        end
#20111103     end # end class << pii_elem
#20111103    end # end def add_virtual_methods_to_pii
end
