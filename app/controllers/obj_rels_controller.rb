class ObjRelsController < ApplicationController
  before_filter :authorize, :except => [:index, :show, :create ]

  # GET /obj_rels
  # GET /obj_rels.xml
  def index
    @obj_rels = ObjRel.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @obj_rels }
    end
  end

  # GET /obj_rels/1
  # GET /obj_rels/1.xml
  def show
    @obj_rel = ObjRel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @obj_rel }
    end
  end

  # GET /obj_rels/new
  # GET /obj_rels/new.xml
  def new
    @obj_rel = ObjRel.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @obj_rel }
    end
  end

  # GET /obj_rels/1/edit
  def edit
    @obj_rel = ObjRel.find(params[:id])
  end

  # POST /obj_rels
  # POST /obj_rels.xml
  def create
    @obj_rel = ObjRel.new(params[:obj_rel])

    respond_to do |format|
      if @obj_rel.save
        format.html { redirect_to(@obj_rel, :notice => 'Obj rel was successfully created.') }
        format.xml  { render :xml => @obj_rel, :status => :created, :location => @obj_rel }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @obj_rel.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /obj_rels/1
  # PUT /obj_rels/1.xml
  def update
    @obj_rel = ObjRel.find(params[:id])

    respond_to do |format|
      if @obj_rel.update_attributes(params[:obj_rel])
        format.html { redirect_to(@obj_rel, :notice => 'Obj rel was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @obj_rel.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /obj_rels/1
  # DELETE /obj_rels/1.xml
  def destroy
    @obj_rel = ObjRel.find(params[:id])
    @obj_rel.destroy

    respond_to do |format|
      format.html { redirect_to(obj_rels_url) }
      format.xml  { head :ok }
    end
  end
end
