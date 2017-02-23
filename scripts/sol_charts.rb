#!/usr/bin/env ruby
require 'spreadsheet'
require 'optparse'
require 'gruff'

SG_COL = 1
# school + 0, division + 1, state + 2 
PASSED_Y1_COL = 3 
PASSED_Y_COL_OFFSET = 3


SCHOOL_NAME_COL = 0 
SCHOOL_NAME_ROW = 2 

YEAR_ROW = 52
ENGLISH_TEST_TYPE_ROW = 54
MATH_TEST_TYPE_ROW = 97
TEST_TYPE_COL = 1
TEST_GROUP_COL = 1
TEST_GRADE_COL = 2
START_SCORE_COL = 3

ALL = 'All Students'
WHI = 'White'
BLA = 'Black'

Y1 = "2013-2014"
Y2 = "2014-2015"
Y3 = "2015-2016"

def getAggregatedStats(sheet, start_row)
  stats = Hash.new { |h,k| h[k] = {} }
  (0..40).step(3) do |gg_offset|
    (0..6).step(PASSED_Y_COL_OFFSET) do |year_offset|
        subgroup = sheet.row(start_row + gg_offset)[SG_COL]
        year = sheet.row(YEAR_ROW)[PASSED_Y1_COL + year_offset]
      rate = sheet.row(start_row + gg_offset)[PASSED_Y1_COL + year_offset]
      stats[subgroup][year] = rate
    end
  end
  stats
end

def findRowByTextInColumn(sheet, col, text)
  sheet.each_with_index do |row, i|
    return i if not row[col].nil? and row[col].include? text
  end
  return -1
end

def printAggregated
  p sheet.row(ENGLISH_TEST_TYPE_ROW)[TEST_TYPE_COL]
  puts getAggregatedStats(sheet, ENGLISH_TEST_TYPE_ROW + 1)

  p sheet.row(MATH_TEST_TYPE_ROW)[TEST_TYPE_COL]
  puts getAggregatedStats(sheet, MATH_TEST_TYPE_ROW + 1)
end

# start_row will be the row with the years
# returns test type, grade level, and a hash of results
def getAssessmentResults(sheet, year_row, start_row)
  stats = Hash.new { |h,k| h[k] = Hash.new { |h,k| h[k] = {} } }
  (0..100).step(3) do |sg_offset| # go down the rows
    subgroup = sheet.row(start_row + sg_offset)[TEST_GROUP_COL]
    break if subgroup.nil? or subgroup.empty? or subgroup.include? 'English: Reading' or subgroup.include? 'Mathematics'
    (START_SCORE_COL..START_SCORE_COL+8).step(4) do |offset| # and across
      year = sheet.row(year_row)[offset]
      stats[subgroup][year][:adv] = sheet.row(start_row + sg_offset)[offset]
      stats[subgroup][year][:pro] = sheet.row(start_row + sg_offset)[offset+1]
      stats[subgroup][year][:fai] = sheet.row(start_row + sg_offset)[offset+3]
    end
  end
  stats
end

def processResults(sheet, year_row, result_start)
  return sheet.row(result_start)[TEST_TYPE_COL],
    sheet.row(result_start)[TEST_GRADE_COL],
    getAssessmentResults(sheet, year_row, result_start + 1)
end

def data_subgroup_year(results, size=800)

  apfs = Hash.new { |h,k| h[k] = [] }

  results['All Students'].each do |year, apf|
    apf.each do |type,score|
      apfs[type] << score
    end
  end

  results['White'].each do |year, apf|
    apf.each do |type,score|
      apfs[type] << score 
    end
  end

  results['Black'].each do |year, apf|
    apf.each do |type,score|
      apfs[type] << score
    end
  end

  g = Gruff::StackedBar.new(size)
  g.title = 'Performance'
  g.labels = {
      0 => '13-14 A',
      1 => '13-14 A',
      2 => '13-14 A',
      3 => '14-15 W',
      4 => '14-15 W',
      5 => '14-15 W',
      6 => '15-16 B',
      7 => '15-16 B',
      8 => '15-16 B',
  }

  apfs.each do |type, scores|
    g.data(type, scores)
  end

  g.write('subgroup_year.png')
end

def is_number? string
  true if Float(string) rescue false
end

def per(r, sg, year, score)
  rate = r[sg][year][score] 
  if is_number? rate 
    rate / r[sg][year].values.inject(0){|sum,x| sum + x } * 100
  else
    0
  end
end

def data_year_subgroup(r, name, size=800)
  g = Gruff::StackedBar.new(size)
  g.title = name
  g.legend_font_size = 14 
  g.bar_spacing = 0.25

  g.labels = {
      0 => '13-14 A',
      1 => '13-14 W',
      2 => '13-14 B',
      3 => '14-15 A',
      4 => '14-15 W',
      5 => '14-15 B',
      6 => '15-16 A',
      7 => '15-16 W',
      8 => '15-16 B',
  }

  g.theme = {   # Declare a custom theme
    :colors => %w(green blue red), # colors can be described on hex values (#0f0f0f)
    :marker_color => 'black', # The horizontal lines color
    :background_colors => %w(white grey) # you can use instead: :background_image => ‘some_image.png’
  }

  apfs = [
   [:all_adv,[per(r,ALL,Y1,:adv),0,0,per(r,ALL,Y2,:adv),0,0,per(r,ALL,Y3,:adv),0,0]], 
   [:all_pro,[per(r,ALL,Y1,:pro),0,0,per(r,ALL,Y2,:pro),0,0,per(r,ALL,Y3,:pro),0,0]], 
   [:all_fai,[per(r,ALL,Y1,:fai),0,0,per(r,ALL,Y2,:fai),0,0,per(r,ALL,Y3,:fai),0,0]], 
   [:whi_adv,[0,per(r,WHI,Y1,:adv),0,0,per(r,WHI,Y2,:adv),0,0,per(r,WHI,Y3,:adv),0]], 
   [:whi_pro,[0,per(r,WHI,Y1,:pro),0,0,per(r,WHI,Y2,:pro),0,0,per(r,WHI,Y3,:pro),0]], 
   [:whi_fail,[0,per(r,WHI,Y1,:fai),0,0,per(r,WHI,Y2,:fai),0,0,per(r,WHI,Y3,:fai),0]], 
   [:bla_adv,[0,0,per(r,BLA,Y1,:adv),0,0,per(r,BLA,Y2,:adv),0,0,per(r,BLA,Y3,:adv)]], 
   [:bla_pro,[0,0,per(r,BLA,Y1,:pro),0,0,per(r,BLA,Y2,:pro),0,0,per(r,BLA,Y3,:pro)]], 
   [:bla_fai,[0,0,per(r,BLA,Y1,:fai),0,0,per(r,BLA,Y2,:fai),0,0,per(r,BLA,Y3,:fai)]]
  ]

  apfs.each do |type, scores|
    g.data(type, scores)
  end

  g.write("year_sg_#{name}.png")
end


# This will hold the options we parse
options = {}

OptionParser.new do |parser|

  # Whenever we see -n or --name, with an 
  # argument, save the argument.
  parser.on("-f", "--file FILE", "The file to read.") do |v|
    options[:file] = v
  end
end.parse!

Spreadsheet.client_encoding = 'UTF-8'
sheet = Spreadsheet.open(options[:file]).worksheet(0)

school_name = sheet.row(SCHOOL_NAME_ROW)[SCHOOL_NAME_COL]

assessment_start = findRowByTextInColumn(sheet, 0, 'Assessment Results at each Proficiency Level by Subgroup')

year_row = assessment_start + 1
# English 3rd
start_row = assessment_start + 3
type, grade, results = processResults(sheet, year_row, start_row)
p results
data_year_subgroup(results, school_name + '_' + type + '_' + grade)

# Math 3rd
start_row = start_row + 1 + 3 * 11
type, grade, results = processResults(sheet, year_row, start_row)
p results
data_year_subgroup(results, school_name + '_' + type + '_' + grade)

# English 4th
start_row = start_row + 1 + 3 * 11
type, grade, results = processResults(sheet, year_row, start_row)
p results
data_year_subgroup(results, school_name + '_' + type + '_' + grade)

# Math 4th
start_row = start_row + 1 + 3 * 10
type, grade, results = processResults(sheet, year_row, start_row)
p results
data_year_subgroup(results, school_name + '_' + type + '_' + grade)
