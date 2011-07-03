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

  def show_out_by_endpoint_id
    logtag = ControllerHelper.gen_logtag
    logger.info("#{File.basename(__FILE__)}:#{self.class}:show_out_by_endpoint_id:#{logtag}, params.inspect:#{params.inspect}")
    endpoint_id = params[:id]
    meantItRels = nil
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_out_by_pii:#{logtag}, endpoint_id:#{endpoint_id}")
    endPoints = EndPoint.find(endpoint_id)
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_out_by_endpoint_id:#{logtag}, endPoints.inspect:#{endPoints.inspect}")
    meantItRels = MeantItRel.where(:src_endpoint_id => endPoints).order("created_at DESC")
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_out_by_endpoint_id:#{logtag}, meantItRels.inspect:#{meantItRels.inspect}")

    respond_to do |format|
      format.html { render "show_meant_it_rels_with_details", :locals => { :meantItRels => meantItRels }  }
      format.xml  { render :xml => meantItRels }
    end
  end # end def show_out_by_endpoint_id

  def show_by_endpoint_endpoint_nick
    logtag = ControllerHelper.gen_logtag
    logger.info("#{File.basename(__FILE__)}:#{self.class}:show_by_endpoint_endpoint_nick:#{logtag}, params.inspect:#{params.inspect}")
    sender_nick = params[:nick1]
    receiver_nick = params[:nick2]
    meantItRels = nil
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_by_endpoint_endpoint_nick:#{logtag}, sender_nick:#{sender_nick}, receiver_nick:#{receiver_nick}")
    sender_endPoints = EndPoint.where(:nick => sender_nick)
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_by_endpoint_id:#{logtag}, sender_endPoints.inspect:#{sender_endPoints.inspect}")
    receiver_endPoints = EndPoint.where(:nick => receiver_nick)
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_by_endpoint_id:#{logtag}, receiver_endPoints.inspect:#{receiver_endPoints.inspect}")
    sender_srcMeantItRels = ControllerHelper.mir_from_ep_srcMeantItRels(sender_endPoints)
    meantItRels = ControllerHelper.mir_from_find_match_dstEndPoints(sender_srcMeantItRels, receiver_endPoints)
    meantItRels = MeantItRel.where(:src_endpoint_id => sender_endPoints, :dst_endpoint_id => receiver_endPoints).order("created_at DESC")
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_by_endpoint_id:#{logtag}, meantItRels.inspect:#{meantItRels.inspect}")

    respond_to do |format|
      format.html { render "show_meant_it_rels_with_details", :locals => { :meantItRels => meantItRels }  }
      format.xml  { render :xml => meantItRels }
    end
  end # end def show_by_endpoint_endpoint_nick

  def show_by_endpoint_endpoint_id
    logtag = ControllerHelper.gen_logtag
    logger.info("#{File.basename(__FILE__)}:#{self.class}:show_by_endpoint_endpoint_id:#{logtag}, params.inspect:#{params.inspect}")
    src_endpoint_id = params[:id1]
    dst_endpoint_id = params[:id2]
    meantItRels = nil
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_by_endpoint_endpoint_id:#{logtag}, endpoint_id:#{endpoint_id}")
    sender_endPoints = EndPoint.find(src_endpoint_id)
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_by_endpoint_id:#{logtag}, sender_endPoints.inspect:#{sender_endPoints.inspect}")
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_by_endpoint_id:#{logtag}, receiver_endPoints.inspect:#{receiver_endPoints.inspect}")
    receiver_endPoints = EndPoint.find(dst_endpoint_id)
    meantItRels = ControllerHelper.mir_from_find_match_dstEndpoints(sender_endPoints.srcMeantItRels, receiver_endPoints)
    meantItRels = MeantItRel.where(:dst_endpoint_id => endPoints).order("created_at DESC")
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_by_endpoint_id:#{logtag}, meantItRels.inspect:#{meantItRels.inspect}")

    respond_to do |format|
      format.html { render "show_meant_it_rels_with_details", :locals => { :meantItRels => meantItRels }  }
      format.xml  { render :xml => meantItRels }
    end
  end # end def show_by_endpoint_endpoint_id

  def show_in_by_endpoint_id
    logtag = ControllerHelper.gen_logtag
    logger.info("#{File.basename(__FILE__)}:#{self.class}:show_in_by_endpoint_id:#{logtag}, params.inspect:#{params.inspect}")
    endpoint_id = params[:id]
    meantItRels = nil
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_in_by_pii:#{logtag}, endpoint_id:#{endpoint_id}")
    endPoints = EndPoint.find(endpoint_id)
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_in_by_endpoint_id:#{logtag}, endPoints.inspect:#{endPoints.inspect}")
    meantItRels = MeantItRel.where(:dst_endpoint_id => endPoints).order("created_at DESC")
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_in_by_endpoint_id:#{logtag}, meantItRels.inspect:#{meantItRels.inspect}")

    respond_to do |format|
      format.html { render "show_meant_it_rels_with_details", :locals => { :meantItRels => meantItRels }  }
      format.xml  { render :xml => meantItRels }
    end
  end # end def show_in_by_endpoint_id

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
    meantItRels = MeantItRel.where(:src_endpoint_id => endPoints).order("created_at DESC")
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_out_by_pii:#{logtag}, meantItRels.inspect:#{meantItRels.inspect}")

    respond_to do |format|
      format.html { render "show_meant_it_rels_with_details", :locals => { :meantItRels => meantItRels }  }
      format.xml  { render :xml => meantItRels }
    end
  end

  def show_in_by_pii
    logtag = ControllerHelper.gen_logtag
    logger.info("#{File.basename(__FILE__)}:#{self.class}:show_in_by_pii:#{logtag}, params.inspect:#{params.inspect}")
    pii_str = params[Constants::PII_VALUE_INPUT]
    meantItRels = nil
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_in_by_pii:#{logtag}, pii_str:#{pii_str}")
    pii = Pii.find_by_pii_value(pii_str)
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_in_by_pii:#{logtag}, pii.inspect:#{pii.inspect}")
    endPoints = pii.endPoints if !pii.nil?
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_in_by_pii:#{logtag}, endPoints.inspect:#{endPoints.inspect}")
    meantItRels = MeantItRel.where(:dst_endpoint_id => endPoints).order("created_at DESC")
    logger.debug("#{File.basename(__FILE__)}:#{self.class}:show_in_by_pii:#{logtag}, meantItRels.inspect:#{meantItRels.inspect}")

    respond_to do |format|
      format.html { render "show_meant_it_rels_with_details", :locals => { :meantItRels => meantItRels }  }
      format.xml  { render :xml => meantItRels }
    end


  end # end def show_by_endpoints
end
