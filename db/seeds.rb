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

SOL_SCORE_DG_CODES = {'All Students' => TOTAL_ALL_COL, 'Female' => FEMALE, 'Male' => MALE, 'Black' => BLACK,
                      'Hispanic' => HISPANIC, 'White' => WHITE, 'Two or more races' => TWO_OR_MORE,
                      'Asian' => ASIAN, 'Native Hawaiian' => NH_PI, 'American Indian' => AM_IN,
                      'Students with Disabilities' => DISABILITIES, 'Economically Disadvantaged' => ECON_DISADV,
                      'English Learners' => ELL, 'Migrant' => MIGRANT}

RESULT_LEVEL_CODES = {'Fail' => 0, 'Proficient' => 1, 'Advanced' => 2}

SCHOOL_NAME_CHANGES = {'Mills E. Godwin Middle' => "George M. Hampton Middle",
                       "Arlington Mill High" => "Arlington Community High", "Byrd Middle" => "Quioccasin Middle",
                       'Campostella Elementary' => 'Southside Stem Academy At Campostella',
                       'Addison Aerospace Magnet Middle' => 'Lucy Addison Aerospace Magnet Middle',
                       'Chesterfield Community High' => 'Carver College And Career Academy',
                       'John Randolph Tucker High' => 'Tucker High',
                       'Jackson Davis Elementary' => 'Davis Elementary',
                       'RC Longan Elementary' => 'Longan Elementary',
                       'Ruby F Carver Elementary' => 'Carver Elementary',
                       'Jacob L Adams Elementary' => 'Adams Elementary',
                       'Elizabeth Holladay Elementary' => 'Holladay Elementary',
                       'Seatack Elementary an Achievable Dream Academy' => 'Seatack Elementary An Achievable Dream Academy',
                       'Quioccasin Middle School' => 'Quioccasin Middle',
                       'LaCrosse Elementary' => 'Lacrosse Elementary'
}

# 'Magruder Elementary' => 'Discovery Stem Academy'}

# Nokesville Elementary/The Nokesville/g
# >s/Mount/Mt./g Olivet
# s/Carver/G.W. Carver/g
# Carver College And Career Academy/Chesterfield Community High

@schools = {}

def lookup_school(school_id, division_id)
  key = school_id.to_s + '_' + division_id.to_s
  if @schools.has_key? (key)
    return @schools[key]
  else
    school = School.find_by school_id: school_id, division_id: division_id
    if not school.nil?
      @schools[key] = school
    else
      puts "error querying for schoolId=#{school_id} divisionId=#{division_id}"
    end
  end
  school
end

###################
# Start of script #
###################

division_name_to_id = {}
school_name_to_school_id = {}
school_name_to_division_id = {}
dgs = []

puts 'Starting seeding...'
start = Time.now

Score.delete_all
Demographic.delete_all
School.delete_all
Division.delete_all

CSV.foreach('db/data/demographic.csv') do |row|
  division_id = row[DIV_ID_COL].strip
  division_name = row[DIV_NAME_COL].strip
  school_id = row[SCHOOL_ID_COL].strip
  school_name = row[SCHOOL_NAME_COL].strip.gsub(/Charter School/, 'Charter').gsub(/\./, '')
  school_name = SCHOOL_NAME_CHANGES[school_name] if SCHOOL_NAME_CHANGES.key?(school_name)

  if not division_name_to_id.has_key? division_name
    division_name_to_id[division_name] = division_id.to_i
    Division.create(id: division_id.to_i, name: division_name)
  end

  key = school_name + '_' + division_name
  school_name_to_division_id[key] = division_id.to_i if not school_name_to_division_id.has_key? key
  if not school_name_to_school_id.has_key? key
    school_name_to_school_id[key] = school_id.to_i
    School.create(school_id: school_id.to_i, division_id: division_id.to_i, name: school_name)
  end

  # grade = row[GRADE_COL].strip
  # year = row[YEAR_COL].strip
  # (HOAR_M_COL..TWOOMR_F_COL).each do |i|
  #   school = lookup_school(school_id, division_id)
  #   if not school.nil?
  #     dgs << Demographic.new(:school_id => school.id, :school_year => year, :grade => grade, :category => i, :count => row[i].strip)
  #   else
  #     puts "demos: school missing for schoolId=#{school_id} divisionId=#{division_id}"
  #     #puts @schools
  #   end
  # end
end


################################
# Demographics 
################################

# p dgs

# Demographic.import dgs

################################
# Scores 
################################

scores = []

CSV.foreach('db/data/scores.csv') do |row|
  next if row.empty?

  school_name = row[0].strip.gsub(/\./, '').gsub(/Charter School/, 'Charter')
  school_name = SCHOOL_NAME_CHANGES[school_name] if SCHOOL_NAME_CHANGES.key?(school_name)

  division_name = row[1].strip.gsub(/ Public Schools/, "")

  key = school_name + '_' + division_name

  school_id = school_name_to_school_id[key]
  if school_id.nil?
    puts "school id '#{school_id.to_s}' is nil for '#{key}'"
    next
  end

  division_id = school_name_to_division_id[key]
  if division_id.nil?
    puts "divison_id '#{division_id.to_s}' is nil for '#{key}'"
    next
  end

  year = row[2].strip
  test_type = row[3].strip
  grade = row[4].strip.gsub(/Grade /, '')
  result_level = row[5].strip
  subgroup = row[6].strip
  percentage = row[7].strip

  if SOL_SCORE_DG_CODES[subgroup].nil?
    p subgroup
    abort
  end

  school = lookup_school(school_id, division_id)
  if not school.nil?
    scores << Score.new(:school_id => school.id, :school_year => year,
                        :test_type => test_type, :grade => grade, :result_level => RESULT_LEVEL_CODES[result_level],
                        :subgroup => SOL_SCORE_DG_CODES[subgroup], :percentage => percentage)
  else
    puts "scores: school missing for schoolId=#{school_id} divisionId=#{division_id}"
  end

end

# p scores

Score.import scores

puts "Ran in %s s" % (Time.now - start).round.to_s
