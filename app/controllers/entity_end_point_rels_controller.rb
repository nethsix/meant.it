class EntityEndPointRelsController < ApplicationController
  before_filter :authorize, :except => [:index, :show, :create ]
  # GET /entity_end_point_rels
  # GET /entity_end_point_rels.xml
  def index
    @entity_end_point_rels = EntityEndPointRel.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @entity_end_point_rels }
    end
  end

  # GET /entity_end_point_rels/1
  # GET /entity_end_point_rels/1.xml
  def show
    @entity_end_point_rel = EntityEndPointRel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @entity_end_point_rel }
    end
  end

  # GET /entity_end_point_rels/new
  # GET /entity_end_point_rels/new.xml
  def new
    @entity_end_point_rel = EntityEndPointRel.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @entity_end_point_rel }
    end
  end

  # GET /entity_end_point_rels/1/edit
  def edit
    @entity_end_point_rel = EntityEndPointRel.find(params[:id])
  end

  # POST /entity_end_point_rels
  # POST /entity_end_point_rels.xml
  def create
    @entity_end_point_rel = EntityEndPointRel.new(params[:entity_end_point_rel])

    respond_to do |format|
      if @entity_end_point_rel.save
        format.html { redirect_to(@entity_end_point_rel, :notice => 'Entity end point rel was successfully created.') }
        format.xml  { render :xml => @entity_end_point_rel, :status => :created, :location => @entity_end_point_rel }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @entity_end_point_rel.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /entity_end_point_rels/1
  # PUT /entity_end_point_rels/1.xml
  def update
    @entity_end_point_rel = EntityEndPointRel.find(params[:id])

    respond_to do |format|
      if @entity_end_point_rel.update_attributes(params[:entity_end_point_rel])
        format.html { redirect_to(@entity_end_point_rel, :notice => 'Entity end point rel was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @entity_end_point_rel.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /entity_end_point_rels/1
  # DELETE /entity_end_point_rels/1.xml
  def destroy
    @entity_end_point_rel = EntityEndPointRel.find(params[:id])
    @entity_end_point_rel.destroy

    respond_to do |format|
      format.html { redirect_to(entity_end_point_rels_url) }
      format.xml  { head :ok }
    end
  end
end
