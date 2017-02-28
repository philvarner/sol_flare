# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

require 'csv'

DIV_ID_COL = 0
DIV_NAME_COL = 1
SCHOOL_ID_COL = 2
SCHOOL_NAME_COL = 3
GRADE_COL = 4
YEAR_COL = 22 # school year, e.g., 2013-2014

# Demographic codes
HOAR_M_COL = 5 # Hispanic/ of any Race Male
HOAR_F_COL = 6 # Hispanic/ of any Race Female
AIAN_M_COL = 7 # American Indian/Alaska Native Male
AIAN_F_COL = 8 # American Indian/Alaska Native Female
ASIAN_M_COL = 9 # Asian Male
ASIAN_F_COL = 10 # Asian Female
BLACK_M_COL = 11 # Black or African American Male
BLACK_F_COL = 12 # Black or African American Female
NHPI_M_COL = 13 # Native Hawaiian/Pacific Islander Male
NHPI_F_COL = 14 # Native Hawaiian/ Pacific Islander Female
WHITE_M_COL = 15 # White Male
WHITE_F_COL = 16 # White Female
TWOOMR_M_COL = 17 # Two or more races  (Non-Hispanic) Male
TWOOMR_F_COL = 18 # Two or more races (Non-Hispanic) Female
TOTAL_FT_COL = 19 # Total Full-time Students
TOTAL_PT_COL = 20 # Part-time Students
TOTAL_ALL_COL = 21 # Total Full-time & Part-time Students / All Students

# SOL Score codes
FEMALE = 100 # Female
MALE = 101 # Male
BLACK = 102 # Black
HISPANIC = 103 # Hispanic
WHITE = 104 # White
ASIAN = 105 # "Asian"
NH_PI = 106 # "Native Hawaiian"
AM_IN = 107 # "American Indian"

TWO_OR_MORE = 200 # Two or more races
DISABILITIES = 201 # Students with Disabilities
ECON_DISADV = 202 # Economically Disadvantaged
ELL = 203 # English Learners
MIGRANT = 204 # Migrant

SOL_SCORE_DG_CODES = {"All Students" => TOTAL_ALL_COL, "Female" => FEMALE, "Male" => MALE, "Black" => BLACK,
                      "Hispanic" => HISPANIC, "White" => WHITE, "Two or more races" => TWO_OR_MORE,
                      "Asian" => ASIAN, "Native Hawaiian" => NH_PI, "American Indian" => AM_IN,
                      "Students with Disabilities" => DISABILITIES, "Economically Disadvantaged" => ECON_DISADV,
                      "English Learners" => ELL, "Migrant" => MIGRANT}

RESULT_LEVEL_CODES = {"Fail" => 0, "Proficient" => 1, "Advanced" => 2}

division_name_to_id = {}
school_name_to_school_id = {}
school_name_to_division_id = {}
dgs = []
score_rows = []

CSV.foreach("db/data/demographic.csv") do |row|
  division_id = row[DIV_ID_COL].strip
  division_name = row[DIV_NAME_COL].strip
  school_id = row[SCHOOL_ID_COL].strip
  school_name = row[SCHOOL_NAME_COL].strip
  division_name_to_id[division_name] = division_id if not division_name_to_id.has_key? division_name
  school_name_to_school_id[school_name] = school_id if not school_name_to_school_id.has_key? school_name
  school_name_to_division_id[school_name] = division_id if not school_name_to_division_id.has_key? school_name

  grade = row[GRADE_COL].strip
  year = row[YEAR_COL].strip
  (HOAR_M_COL..TWOOMR_F_COL).each do |i|
    dgs << {:school_id => school_id, :division_id => division_id, :school_year => year,
            :grade => grade, :category => i, :count => row[i].strip}
  end

end

Score.delete_all
Demographic.delete_all
School.delete_all
Division.delete_all

################################
# Districts
################################

# p division_name_to_id

Division.transaction do
  division_name_to_id.each do |name, id|
    Division.create(id: id, name: name)
  end
end

################################
# Schools
################################

# p school_name_to_school_id

School.transaction do
  school_name_to_school_id.each do |name, id|
    School.create(school_id: id, name: name, division_id: school_name_to_division_id[name])
  end
end

################################
# Demographics 
################################

# p dgs

Demographic.transaction do
  Demographic.create(dgs)
end

################################
# Scores 
################################

scores = []
CSV.foreach("db/data/scores.csv") do |row|
  next if row.empty?

  school_name = row[0].strip
  school_id = school_name_to_school_id[school_name]
  division_id = school_name_to_division_id[school_name]
  # division_name = row[1].strip.gsub(/ Public Schools/, "") 
  year = row[2].strip
  test_type = row[3].strip
  grade = row[4].strip.gsub(/Grade /, "")
  result_level = row[5].strip
  subgroup = row[6].strip
  percentage = row[7].strip

  if SOL_SCORE_DG_CODES[subgroup].nil?
    p subgroup
    abort
  end

  scores << {:school_id => school_id, :division_id => division_id, :school_year => year,
             :test_type => test_type, :grade => grade, :result_level => RESULT_LEVEL_CODES[result_level],
             :subgroup => SOL_SCORE_DG_CODES[subgroup], :percentage => percentage
  }
end

# p scores

Score.transaction do
  Score.create(scores)
end

