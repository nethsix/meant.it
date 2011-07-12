class EndPointTagRelsController < ApplicationController
  before_filter :authorize, :except => [:index, :show, :create ]

  # GET /end_point_tag_rels
  # GET /end_point_tag_rels.xml
  def index
    @end_point_tag_rels = EndPointTagRel.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @end_point_tag_rels }
    end
  end

  # GET /end_point_tag_rels/1
  # GET /end_point_tag_rels/1.xml
  def show
    @end_point_tag_rel = EndPointTagRel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @end_point_tag_rel }
    end
  end

  # GET /end_point_tag_rels/new
  # GET /end_point_tag_rels/new.xml
  def new
    @end_point_tag_rel = EndPointTagRel.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @end_point_tag_rel }
    end
  end

  # GET /end_point_tag_rels/1/edit
  def edit
    @end_point_tag_rel = EndPointTagRel.find(params[:id])
  end

  # POST /end_point_tag_rels
  # POST /end_point_tag_rels.xml
  def create
    @end_point_tag_rel = EndPointTagRel.new(params[:end_point_tag_rel])

    respond_to do |format|
      if @end_point_tag_rel.save
        format.html { redirect_to(@end_point_tag_rel, :notice => 'End point tag rel was successfully created.') }
        format.xml  { render :xml => @end_point_tag_rel, :status => :created, :location => @end_point_tag_rel }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @end_point_tag_rel.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /end_point_tag_rels/1
  # PUT /end_point_tag_rels/1.xml
  def update
    @end_point_tag_rel = EndPointTagRel.find(params[:id])

    respond_to do |format|
      if @end_point_tag_rel.update_attributes(params[:end_point_tag_rel])
        format.html { redirect_to(@end_point_tag_rel, :notice => 'End point tag rel was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @end_point_tag_rel.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /end_point_tag_rels/1
  # DELETE /end_point_tag_rels/1.xml
  def destroy
    @end_point_tag_rel = EndPointTagRel.find(params[:id])
    @end_point_tag_rel.destroy

    respond_to do |format|
      format.html { redirect_to(end_point_tag_rels_url) }
      format.xml  { head :ok }
    end
  end
end
