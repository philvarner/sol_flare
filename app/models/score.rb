require_relative 'codes.rb'

class Score < ApplicationRecord

  include Filterable

  belongs_to :school

  scope :school_id, -> (school_id) { where school_id: school_id }
  scope :school_year, -> (school_year) { where school_year: school_year }
  scope :test_type, -> (test_type) { where test_type: test_type }
  scope :grade, -> (grade) { where grade: grade }
  scope :result_level, -> (result_level) { where result_level: result_level }
  scope :subgroup, -> (subgroup) { where subgroup: subgroup }

  include Codes

  def subgroup_name
    Codes.demo_code(subgroup)
  end

  def result_level_name
    Codes.level_code(result_level)
  end

  # def as_json(options)
  #   super( :only => [ :school_id ] )
  # end
end