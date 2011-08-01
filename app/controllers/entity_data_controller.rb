class EntityDataController < ApplicationController
#  before_filter :authorize, :except => [:index, :show, :create ]
#  before_filter :authorize, :except => [:create ]
  before_filter :logged_in, :except => [:new]
  before_filter :no_profile?, :only => [:new]

  # GET /entity_data
  # GET /entity_data.xml
  def index
    if admin?
      @entity_data = EntityDatum.all
    else
      @entity_data = EntityDatum.find current_entity.property_document_id
    end # end if admin?
#logger.info "#{File.basename(__FILE__)}.index:#{@entity_data.inspect}"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @entity_data }
    end
  end

  # GET /entity_data/1
  # GET /entity_data/1.xml
  def show
    if admin?
      @entity_datum = EntityDatum.find(params[:id])
    else
      @entity_datum = EntityDatum.find current_entity.property_document_id
    end # end if admin?

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @entity_datum }
    end
  end

  # GET /entity_data/new
  # GET /entity_data/new.xml
  def new
    @entity_datum = EntityDatum.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @entity_datum }
    end
  end

  # GET /entity_data/1/edit
  def edit
    if admin?
      @entity_datum = EntityDatum.find(params[:id])
    else
      @entity_datum = EntityDatum.find current_entity.property_document_id
    end # end if admin?
  end

  # POST /entity_data
  # POST /entity_data.xml
  def create
    logtag = ControllerHelper.gen_logtag
    # Check if email already exists
    if admin? or current_entity.property_document_id.nil?
      @entity_datum = EntityDatum.new(params[:entity_datum])
    end # end if admin?

#20110801    chosen_email = params[:entity_datum][:email]
#20110801    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, chosen_email:#{chosen_email}")
#20110801    entity_datum_exist = EntityDatum.find_by_email(chosen_email)

#20110801    entity_datum_error = nil
#20110801    if entity_datum_exist.nil?
#20110801      @entity_datum.save
#20110801      entity_datum_error = @entity_datum.errors.any? ? true : false
#20110801    end # end if entity_datum_exist.nil?

#20110801    # Possible conditions:
#20110801    #                                entity_datum_error
#20110801    # entity_datum_exist    |      nil      true           false
#20110801    #       nil             |       x     show error      link (new)
#20110801    #     not nil           | link (exist)      x            x
   
#20110801    # Link to entity if entity data was successfully saved
#20110801    if (entity_datum_exist.nil? and entity_datum_error == false) or (!entity_datum_exist.nil? and entity_datum_error.nil?)
#20110801      if (entity_datum_exist.nil? and entity_datum_error == false)
#20110801        current_entity.property_document_id = @entity_datum.id
#20110801      elsif (!entity_datum_exist.nil? and entity_datum_error.nil?)
#20110801        current_entity.property_document_id = entity_datum_exist.id
#20110801      end # end elsif (!entity_datum_exist.nil? and entity_datum_error.nil?)
    if @entity_datum.save
      current_entity.property_document_id = @entity_datum.id
      if current_entity.save
        logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, setting property_document_id:#{@entity_datum.id} for current_entity.inspect:#{current_entity.inspect}")
        respond_to do |format|
          format.html { redirect_to("/", :notice => 'Entity datum was successfully created.') }
          format.xml  { render :xml => @entity_datum, :status => :created, :location => @entity_datum }
        end # end respond_to
      else
        logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, setting property_document_id failed for pair: current_entity.inspect:#{current_entity.inspect}, entity_datum.inspect:#{@entity_datum.inspect}")
        logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, current_entity.errors.inspect:#{current_entity.errors.inspect}")
        respond_to do |format|
          format.html { redirect_to "/", :error => "setting property_document_id failed failed" }
        end # end respond_to
      end # end if current_entity.save
    else
#      flash.now[:error] = "Another entity already using the email '#{chosen_email}'" if !entity_datum_exist.nil?
      respond_to do |format|
        format.html { render :action => "new" }
        format.xml  { render :xml => @entity_datum.errors, :status => :unprocessable_entity }
      end # end respond_to
    end # end if current_entity.save ...
  end # end if @entity_datum.save ...

  # PUT /entity_data/1
  # PUT /entity_data/1.xml
  def update
    logtag = ControllerHelper.gen_logtag
    if admin?
      @entity_datum = EntityDatum.find(params[:id])
    else
      @entity_datum = EntityDatum.find current_entity.property_document_id
    end # end if admin?

    # Check if email already exists
#20110801    chosen_email = params[:entity_datum][:email]
#20110801    logger.debug("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:update:#{logtag}, chosen_email:#{chosen_email}")
#20110801    entity_datum_exist = EntityDatum.find_by_email(chosen_email)

    respond_to do |format|
#20110801      if entity_datum_exist.nil? and @entity_datum.update_attributes(params[:entity_datum])
      if @entity_datum.update_attributes(params[:entity_datum])
        format.html { redirect_to("/", :notice => 'Entity datum updated.') }
        format.xml  { head :ok }
      else
#20110801        flash.now[:error] = "Another entity already using the email '#{chosen_email}'" if !entity_datum_exist.nil?
        format.html { render :action => "edit" }
        format.xml  { render :xml => @entity_datum.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /entity_data/1
  # DELETE /entity_data/1.xml
  def destroy
    if admin?
      @entity_datum = EntityDatum.find(params[:id])
      @entity_datum.destroy
    else 
      if current_entity.id == params[:id]
        @entity_datum = EntityDatum.find(params[:id])
        @entity_datum.destroy
      end # end if current_entity.id == params[:id]
    end

    respond_to do |format|
      format.html { redirect_to(entity_data_url) }
      format.xml  { head :ok }
    end
  end
end
