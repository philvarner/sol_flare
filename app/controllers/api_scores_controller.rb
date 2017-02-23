class ApiScoresController < ApplicationController

  def index
    render json: Result.where("school_name = 'Clark Elementary' and subgroup = 'Black' and school_year = '2015-2016' and result_level = 'adv'")
  end

end
