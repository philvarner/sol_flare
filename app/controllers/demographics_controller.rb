class DemographicsController < ApplicationController

  def index
    @ds = Demographic.all
  end

  def show
    @d = Demographic.find(params[:id])
  end

end
