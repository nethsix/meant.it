class InboundEmailLogsController < ApplicationController
#  before_filter :authorize, :except => [:index, :show, :create ]
  before_filter :authorize, :except => [:create ]
  # GET /inbound_email_logs
  # GET /inbound_email_logs.xml
  def index
    @inbound_email_logs = InboundEmailLog.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @inbound_email_logs }
    end
  end

  # GET /inbound_email_logs/1
  # GET /inbound_email_logs/1.xml
  def show
    @inbound_email_log = InboundEmailLog.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @inbound_email_log }
    end
  end

  # GET /inbound_email_logs/new
  # GET /inbound_email_logs/new.xml
  def new
    @inbound_email_log = InboundEmailLog.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @inbound_email_log }
    end
  end

  # GET /inbound_email_logs/1/edit
  def edit
    @inbound_email_log = InboundEmailLog.find(params[:id])
  end

  # POST /inbound_email_logs
  # POST /inbound_email_logs.xml
  def create
    @inbound_email_log = InboundEmailLog.new(params[:inbound_email_log])

    respond_to do |format|
      if @inbound_email_log.save
        format.html { redirect_to(@inbound_email_log, :notice => 'Inbound email log was successfully created.') }
        format.xml  { render :xml => @inbound_email_log, :status => :created, :location => @inbound_email_log }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @inbound_email_log.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /inbound_email_logs/1
  # PUT /inbound_email_logs/1.xml
  def update
    @inbound_email_log = InboundEmailLog.find(params[:id])

    respond_to do |format|
      if @inbound_email_log.update_attributes(params[:inbound_email_log])
        format.html { redirect_to(@inbound_email_log, :notice => 'Inbound email log was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @inbound_email_log.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /inbound_email_logs/1
  # DELETE /inbound_email_logs/1.xml
  def destroy
    @inbound_email_log = InboundEmailLog.find(params[:id])
    @inbound_email_log.destroy

    respond_to do |format|
      format.html { redirect_to(inbound_email_logs_url) }
      format.xml  { head :ok }
    end
  end
end
