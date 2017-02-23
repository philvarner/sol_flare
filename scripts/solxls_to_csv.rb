#!/usr/bin/env ruby
require 'spreadsheet'
require 'csv'

SG_COL = 1
# school + 0, division + 1, state + 2 
PASSED_Y1_COL = 3 
PASSED_Y_COL_OFFSET = 3

SCHOOL_NAME_COL = 0 
SCHOOL_NAME_ROW = 2 
DISTRICT_NAME_ROW = SCHOOL_NAME_ROW + 5

YEAR_ROW = 52
TEST_TYPE_COL = 1
TEST_GROUP_COL = 1
TEST_GRADE_COL = 2
START_SCORE_COL = 3
TEST_TYPE_BLANK_COL = 3

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

# start_row will be the row with the years
# returns test type, grade level, and a hash of results
def getAssessmentResults(sheet, year_row, start_row)
  stats = Hash.new { |h,k| h[k] = Hash.new { |h,k| h[k] = {} } }
  (0..100).step(3) do |sg_offset| # go down the rows
    blank = sheet.row(start_row + sg_offset)[TEST_TYPE_BLANK_COL]
    return start_row + sg_offset, stats if blank.nil? or (blank.is_a? String and blank.empty?)
    subgroup = sheet.row(start_row + sg_offset)[TEST_GROUP_COL]
    (START_SCORE_COL..START_SCORE_COL+8).step(4) do |offset| # and across
      year = sheet.row(year_row)[offset]
      stats[subgroup][year]['Advanced'] = sheet.row(start_row + sg_offset)[offset]
      stats[subgroup][year]['Proficient'] = sheet.row(start_row + sg_offset)[offset+1]
      stats[subgroup][year]['Fail'] = sheet.row(start_row + sg_offset)[offset+3]
    end
  end
  # maybe need a fall-through?
end

def create_entries(school, district, type, grade, results) 
  entries = []
  results.each_pair { |subgroup, years| 
    years.each_pair { |year, scores|
      scores.each_pair { |score,percent|
        entries << [school, district, year, type, grade.strip, score, subgroup, ((percent.is_a? Numeric) ? percent.round(0) : percent)]
      }}}
  entries
end

def proc_spreadsheet(filename)

  Spreadsheet.client_encoding = 'UTF-8'
  sheet = Spreadsheet.open(filename).worksheet(0)

  school_name = sheet.row(SCHOOL_NAME_ROW)[SCHOOL_NAME_COL]
  district_name = sheet.row(DISTRICT_NAME_ROW)[SCHOOL_NAME_COL]

  assessment_start = findRowByTextInColumn(sheet, 0, 'Assessment Results at each Proficiency Level by Subgroup')
  year_row = assessment_start + 1
  start_row = assessment_start + 3

  entries = []

  (0..100).step(1) do |x|
    type = sheet.row(start_row)[TEST_TYPE_COL]
    break if type.nil? or type.empty?
    grade = sheet.row(start_row)[TEST_GRADE_COL]
    start_row, results = getAssessmentResults(sheet, year_row, start_row+1)
    entries += create_entries(school_name, district_name, type, grade, results)
  end

  csv_string = CSV.generate do |csv|
    entries.each do |entry|
      csv << entry
    end
  end
  csv_string
end

ARGV.each do |f|
  puts proc_spreadsheet(f)
end
