#!/usr/bin/env ruby
require 'spreadsheet'
require 'csv'

def proc_spreadsheet(filename)

  Spreadsheet.client_encoding = 'UTF-8'
  sheet = Spreadsheet.open(filename).worksheet(0)

  year_row = sheet.row(1)[0][0..8]

  csv_string = CSV.generate do |csv|
    sheet.each 5 do |erow|
      next if erow[0].nil?
      row = erow.to_a
      row.push year_row
      row[1] = row[1]
                     .gsub(/ PBLC SCHS/,'')
                     .gsub(/ CO/,' County')
                     .gsub(/ Cty/,' City')
                     .gsub(/[A-Za-z']+/,&:capitalize).strip
      row[3] = row[3].gsub(/ ELEM/,' Elementary').gsub(/[A-Za-z']+/,&:capitalize)
      row = row.map { |entry| entry.respond_to?(:round) ? entry.round : entry }
      csv << row
    end
  end
  csv_string
end

ARGV.each do |f|
  puts proc_spreadsheet(f)
end
