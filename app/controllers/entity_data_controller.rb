class EntityDataController < ApplicationController
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
    if admin? or current_entity.property_document_id.nil?
      @entity_datum = EntityDatum.new(params[:entity_datum])
    end # end if admin?

    if @entity_datum.save
      current_entity.property_document_id = @entity_datum.id
      if current_entity.save
        logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, setting property_document_id:#{@entity_datum.id} for current_entity.inspect:#{current_entity.inspect}")
        respond_to do |format|
          format.html { redirect_to(@entity_datum, :notice => 'Entity datum was successfully created.') }
          format.xml  { render :xml => @entity_datum, :status => :created, :location => @entity_datum }
        end # end respond_to
      else
        logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, setting property_document_id failed for pair: current_entity.inspect:#{current_entity.inspect}, entity_datum.inspect:#{@entity_datum.inspect}")
        logger.error("#{File.basename(__FILE__)}:#{self.class}:#{Time.now}:create:#{logtag}, current_entity.errors.inspect:#{current_entity.errors.inspect}")
        respond_to do |format|
          format.html { render "/" }
        end # end respond_to
      end # end if current_entity.save
    else
      respond_to do |format|
        format.html { render :action => "new" }
        format.xml  { render :xml => @entity_datum.errors, :status => :unprocessable_entity }
      end # end respond_to
    end # end if current_entity.save ...
  end # end if @entity_datum.save ...

  # PUT /entity_data/1
  # PUT /entity_data/1.xml
  def update
    if admin?
      @entity_datum = EntityDatum.find(params[:id])
    else
      @entity_datum = EntityDatum.find current_entity.property_document_id
    end # end if admin?

    respond_to do |format|
      if @entity_datum.update_attributes(params[:entity_datum])
        format.html { redirect_to(@entity_datum, :notice => 'Entity datum was successfully updated.') }
        format.xml  { head :ok }
      else
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
