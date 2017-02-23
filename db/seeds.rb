# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'csv'

district_name_to_id = { }
school_name_to_id = { }
school_name_to_district_id = { }

CSV.foreach("db/districts.csv") do |row|
  district_name_to_id[row[1].strip] = row[0].strip
  #District.create(id: row[0], name: row[1])
end

#p district_name_to_id

CSV.foreach("db/schools.csv") { |row| school_name_to_id[row[1].strip] = row[0].strip }

#p school_name_to_id

CSV.foreach("db/scores.csv") { |row| 
  next if row.empty?
  district = row[1].strip.gsub(/ Public Schools/, "") 
  if school_name_to_district_id[row[0].strip].nil?
    school_name_to_district_id[row[0].strip] = district_name_to_id[district]
    #School.create(id: row[0].strip, name: row[1].strip, district_id: school_name_to_district_id[row[1].strip])
  end

=begin
  Score.create(school_id: school_name_to_id[row[0]], 
      school_year: row[2],
      test_type: row[3],
      grade: row[4],
      result_level: row[5],
      subgroup: row[6],
      percentage: row[7])
=end
}

p school_name_to_district_id
