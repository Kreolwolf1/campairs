class CampaingsController < ApplicationController
  respond_to :json, :html

  def index
    @campaings = Campaing.all

    respond_with @campaings
  end

  def show
    @campaing = Campaing.find(params[:id])

    respond_with @campaing
  end

  def new
    @campaing = Campaing.new

    respond_with @campaing
  end

  def create
    puts params[:campaing]
    @campaing = Campaing.create(params[:campaing])

    respond_with @campaing
  end

  def destroy
    @campaing = Campaing.find(params[:id])
    @campaing.destroy

    respond_with :no_content
  end
end
