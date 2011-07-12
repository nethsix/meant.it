class EntityDataController < ApplicationController
  before_filter :authorize, :except => [:index, :show, :create ]

  # GET /entity_data
  # GET /entity_data.xml
  def index
    @entity_data = EntityDatum.all
#logger.info "#{File.basename(__FILE__)}.index:#{@entity_data.inspect}"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @entity_data }
    end
  end

  # GET /entity_data/1
  # GET /entity_data/1.xml
  def show
    @entity_datum = EntityDatum.find(params[:id])

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
    @entity_datum = EntityDatum.find(params[:id])
  end

  # POST /entity_data
  # POST /entity_data.xml
  def create
    @entity_datum = EntityDatum.new(params[:entity_datum])

    respond_to do |format|
      if @entity_datum.save
        format.html { redirect_to(@entity_datum, :notice => 'Entity datum was successfully created.') }
        format.xml  { render :xml => @entity_datum, :status => :created, :location => @entity_datum }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @entity_datum.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /entity_data/1
  # PUT /entity_data/1.xml
  def update
    @entity_datum = EntityDatum.find(params[:id])

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
    @entity_datum = EntityDatum.find(params[:id])
    @entity_datum.destroy

    respond_to do |format|
      format.html { redirect_to(entity_data_url) }
      format.xml  { head :ok }
    end
  end
end
