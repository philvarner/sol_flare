class ScoresController < ApplicationController

  def index

    subgroups = params[:subgroup].split(',').map{|e| e.to_i}

    @scores = Score.filter(params.slice(:school_id, :school_year, :test_type, :grade, :result_level)).where(:subgroup => subgroups)

    p @scores

    respond_to do |format|
      format.html
      format.json { render json: @scores }
      format.jsonapi {
        hscores = Hash.new { |hash, key| hash[key] = Hash.new(&hash.default_proc) }
        @scores.each do |s|
          hscores[s.school_id][s.school_year][s.test_type][s.grade][s.subgroup][s.result_level] = s.percentage
        end

        fscores = []

        hscores.each do |school_id, results_by_year|
          results_by_year.each do |year, test_types|
            test_types.each do |test_type, by_grade|
              by_grade.each do |grade, demo|
                demo.each do |demo_code, percentages|
                  results = []
                  percentages.each do |level, percentage|
                    results << {:level => level, :percentage => percentage}
                  end
                  fscores << {:school_id => school_id,
                              :year => year, :type => test_type,
                              :grade => grade,
                              :dcode => demo_code,
                              :dcode_name => Codes.demo_code(demo_code),
                              :results => results}
                end
              end
            end
          end
        end

        render json: {:scores => fscores}
      }
    end

  end

  def show

    @score = Score.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @score }
    end

  end

  def chart

    @schools = School.includes(:division).order("divisions.name asc").order(:name)

  end

end
