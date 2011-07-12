class MeantItMoodTagRelsController < ApplicationController
  before_filter :authorize, :except => [:index, :show, :create ]

  # GET /meant_it_mood_tag_rels
  # GET /meant_it_mood_tag_rels.xml
  def index
    @meant_it_mood_tag_rels = MeantItMoodTagRel.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @meant_it_mood_tag_rels }
    end
  end

  # GET /meant_it_mood_tag_rels/1
  # GET /meant_it_mood_tag_rels/1.xml
  def show
    @meant_it_mood_tag_rel = MeantItMoodTagRel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @meant_it_mood_tag_rel }
    end
  end

  # GET /meant_it_mood_tag_rels/new
  # GET /meant_it_mood_tag_rels/new.xml
  def new
    @meant_it_mood_tag_rel = MeantItMoodTagRel.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @meant_it_mood_tag_rel }
    end
  end

  # GET /meant_it_mood_tag_rels/1/edit
  def edit
    @meant_it_mood_tag_rel = MeantItMoodTagRel.find(params[:id])
  end

  # POST /meant_it_mood_tag_rels
  # POST /meant_it_mood_tag_rels.xml
  def create
    @meant_it_mood_tag_rel = MeantItMoodTagRel.new(params[:meant_it_mood_tag_rel])

    respond_to do |format|
      if @meant_it_mood_tag_rel.save
        format.html { redirect_to(@meant_it_mood_tag_rel, :notice => 'Meant it mood tag rel was successfully created.') }
        format.xml  { render :xml => @meant_it_mood_tag_rel, :status => :created, :location => @meant_it_mood_tag_rel }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @meant_it_mood_tag_rel.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /meant_it_mood_tag_rels/1
  # PUT /meant_it_mood_tag_rels/1.xml
  def update
    @meant_it_mood_tag_rel = MeantItMoodTagRel.find(params[:id])

    respond_to do |format|
      if @meant_it_mood_tag_rel.update_attributes(params[:meant_it_mood_tag_rel])
        format.html { redirect_to(@meant_it_mood_tag_rel, :notice => 'Meant it mood tag rel was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @meant_it_mood_tag_rel.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /meant_it_mood_tag_rels/1
  # DELETE /meant_it_mood_tag_rels/1.xml
  def destroy
    @meant_it_mood_tag_rel = MeantItMoodTagRel.find(params[:id])
    @meant_it_mood_tag_rel.destroy

    respond_to do |format|
      format.html { redirect_to(meant_it_mood_tag_rels_url) }
      format.xml  { head :ok }
    end
  end
end
