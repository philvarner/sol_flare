class ScoresController < ApplicationController

  def index

    @scores = Score.filter(params.slice(:school_id, :school_year, :test_type, :grade, :result_level, :subgroup))

    respond_to do |format|
      format.html
      format.json { render json: @scores }
    end

  end

  def show

    @score = Score.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @score }
    end

  end

end
