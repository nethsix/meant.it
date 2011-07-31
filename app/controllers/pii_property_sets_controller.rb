require 'controller_helper'

class PiiPropertySetsController < ApplicationController

  # GET /pii_property_sets/new
  # GET /pii_property_sets/new.xml
  def new
    @pii_property_set  = PiiPropertySet.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pii_property_set }
    end
  end

  # GET /pii_property_sets/1/edit
  def edit
    @pii_property_set = PiiPropertySet.find(params[:id])
  end

  # POST /pii_property_sets
  # POST /pii_property_sets.xml
  def create
    @pii_property_set = PiiPropertySet.new(params[:pii_property_set])
    pii = Pii.find_by_pii_value(params[Constants::PII_VALUE_INPUT])
    pii.pii_property_set = @pii_property_set

    respond_to do |format|
      if @pii_property_set.save
        format.html { redirect_to("/", :notice => 'Pii property set was successfully created.') }
        format.xml  { render :xml => @pii_property_set, :status => :created, :location => @pii_property_set }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pii_property_set.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pii_property_sets/1
  # PUT /pii_property_sets/1.xml
  def update
    @pii_property_set = PiiPropertySet.find(params[:id])

    respond_to do |format|
      if @pii_property_set.update_attributes(params[:pii_property_set])
        format.html { redirect_to("/", :notice => 'Pii property set  was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pii_property_set.errors, :status => :unprocessable_entity }
      end
    end
  end
end
