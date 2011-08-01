require 'controller_helper'

class PiisController < ApplicationController
#  before_filter :authorize, :except => [:index, :show, :create, :show_by_pii_value ]
  before_filter :authorize, :except => [:create, :show_by_pii_value, :show_by_message_type_uniq_sender_count ]

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

  def show_by_message_type_uniq_sender_count
    logtag = ControllerHelper.gen_logtag
    logger.info("#{File.basename(__FILE__)}:#{self.class}:show_by_message_type_count:#{logtag}, params.inspect:#{params.inspect}")
    order = params[Constants::COUNT_ORDER_INPUT]
    order = ControllerHelper.sql_validate_order(order, Constants::SQL_COUNT_ORDER_DESC)
    rec_limit = params[Constants::REC_LIMIT_INPUT]
    rec_limit = ControllerHelper.validate_number(rec_limit, Constants::LIKEBOARD_REC_LIMIT)
    message_type = params[Constants::MESSAGE_TYPE_INPUT]
    pii_value = params[Constants::PII_VALUE_INPUT]
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_by_message_type_count:#{logtag}, message_type:#{message_type}, pii_value:#{pii_value}")
    options = { :select => "piis.pii_value, piis.status, piis.pii_hide, count(*) as mir_count", :joins => ["JOIN end_points on piis.id = end_points.pii_id",  "JOIN meant_it_rels on meant_it_rels.dst_endpoint_id = end_points.id"], :group => "piis.pii_value, piis.status, piis.pii_hide", :limit => rec_limit, :order => "mir_count #{order}" }
    if !message_type.nil? and !message_type.empty?
      normalized_msg_type_downcase = MessageTypeMapper.get_message_type(message_type.downcase)
#      if options[:conditions].nil?
#        options[:conditions] = ["meant_it_rels.message_type = ?", normalized_msg_type_downcase]
#        options[:conditions] = { :meant_it_rels => { :message_type => normalized_msg_type_downcase} }
#      end # end if options[:conditions].nil?
      ControllerHelper.set_options(options, :conditions, :meant_it_rels, :message_type, normalized_msg_type_downcase)
    end # end if !message_type.nil? and !message_type.empty?
    if !pii_value.nil? and !pii_value.empty?
      ControllerHelper.set_options(options, :conditions, :piis, :pii_value, pii_value)
    end # end if !pii_value.nil? and !pii_value.empty?
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_by_message_type_count:#{logtag}, options.inspect:#{options.inspect}")
    @pii = Pii.find(:all, options)
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

#        def as_json(options={})
#          super(
#            :methods => %w{:short_desc_data :long_desc_data :thumbnail_url_data }
#          )
#        end 
      end
      logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_by_message_type_uniq_sender_count:#{logtag}, pii_elem.short_desc_data:#{pii_elem.short_desc_data}")
    }
    pii_to_json = @pii.to_json(:methods => [:threshold, :formula, :short_desc_data, :long_desc_data, :thumbnail_url_data])
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_by_message_type_uniq_sender_count:#{logtag}, pii_to_json:#{pii_to_json}")

    respond_to do |format|
#      format.html { render "show_pii_details", :layout => "find_any", :locals => { :find_any_input => find_any_input } }
      format.xml  { render :xml => @pii }
      format.json { render :json => pii_to_json }
    end
#      format.html { render "show_meant_it_rels_with_details", :layout => "find_any", :locals => { :meantItRels => meantItRels, :find_any_input => find_any_input_str, :title_str => title_str, :down_url => down_url, :up_url => up_url }  }
#      format.xml  { render :xml => meantItRels }
  end # end def show_by_message_type_uniq_sender_count
end
