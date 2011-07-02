require 'constants'

class MeantItRelsController < ApplicationController
  # GET /meant_it_rels
  # GET /meant_it_rels.xml
  def index
    @meant_it_rels = MeantItRel.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @meant_it_rels }
    end
  end

  # GET /meant_it_rels/1
  # GET /meant_it_rels/1.xml
  def show
    @meant_it_rel = MeantItRel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @meant_it_rel }
    end
  end

  # GET /meant_it_rels/new
  # GET /meant_it_rels/new.xml
  def new
    @meant_it_rel = MeantItRel.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @meant_it_rel }
    end
  end

  # GET /meant_it_rels/1/edit
  def edit
    @meant_it_rel = MeantItRel.find(params[:id])
  end

  # POST /meant_it_rels
  # POST /meant_it_rels.xml
  def create
    @meant_it_rel = MeantItRel.new(params[:meant_it_rel])

    respond_to do |format|
      if @meant_it_rel.save
        format.html { redirect_to(@meant_it_rel, :notice => 'Meant it rel was successfully created.') }
        format.xml  { render :xml => @meant_it_rel, :status => :created, :location => @meant_it_rel }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @meant_it_rel.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /meant_it_rels/1
  # PUT /meant_it_rels/1.xml
  def update
    @meant_it_rel = MeantItRel.find(params[:id])

    respond_to do |format|
      if @meant_it_rel.update_attributes(params[:meant_it_rel])
        format.html { redirect_to(@meant_it_rel, :notice => 'Meant it rel was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @meant_it_rel.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /meant_it_rels/1
  # DELETE /meant_it_rels/1.xml
  def destroy
    @meant_it_rel = MeantItRel.find(params[:id])
    @meant_it_rel.destroy

    respond_to do |format|
      format.html { redirect_to(meant_it_rels_url) }
      format.xml  { head :ok }
    end
  end

  def show_out_by_pii
    logtag = ControllerHelper.gen_logtag
    logger.info("#{File.basename(__FILE__)}:#{self.class}:show_out_by_pii:#{logtag}, params.inspect:#{params.inspect}")
    pii_str = params[Constants::PII_VALUE_INPUT]
    meantItRels = nil
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_out_by_pii:#{logtag}, pii_str:#{pii_str}")
    pii = Pii.find_by_pii_value(pii_str)
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_out_by_pii:#{logtag}, pii.inspect:#{pii.inspect}")
    endPoints = pii.endPoints if !pii.nil?
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_out_by_pii:#{logtag}, endPoints.inspect:#{endPoints.inspect}")
    meantItRels = ControllerHelper.mir_from_ep_meantItRels(endPoints) if !endPoints.nil?
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_out_by_pii:#{logtag}, meantItRels.inspect:#{meantItRels.inspect}")

    respond_to do |format|
      format.html { render "show_meant_it_rels_with_details", :locals => { :meantItRels => meantItRels }  }
      format.xml  { render :xml => meantItRels }
    end


  end # end def show_by_endpoints
end
