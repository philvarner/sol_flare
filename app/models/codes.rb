module Codes

  @demo_codes = {
      5 => "Hispanic Male",
      6 => "Hispanic Female",
      7 => "American Indian/Alaska Native Male",
      8 => "American Indian/Alaska Native Female",
      9 => "Asian Male",
      10 => "Asian Female",
      11 => "Black or African American Male",
      12 => "Black or African American Female",
      13 => "Native Hawaiian/Pacific Islander Male",
      14 => "Native Hawaiian/Pacific Islander Female",
      15 => "White Male",
      16 => "White Female",
      17 => "Two or more races  (Non-Hispanic) Male",
      18 => "Two or more races (Non-Hispanic) Female",
      19 => "Total Full-time Students",
      20 => "Part-time Students",
      21 => "All Students",
      100 => "Female",
      101 => "Male",
      102 => "Black",
      103 => "Hispanic",
      104 => "White",
      105 => "Asian",
      106 => "Native Hawaiian",
      107 => "American Indian",
      200 => "Two or more races",
      201 => "Students with Disabilities",
      202 => "Economically Disadvantaged",
      203 => "English Learners",
      204 => "Migrant"
  }

  def self.demo_code(id)
    @demo_codes[id]
  end

  @level_codes = {
      0 => "Fail",
      1 => "Proficient",
      2 => "Advanced"
  }

  def self.level_code(id)
    @level_codes[id]
  end

end