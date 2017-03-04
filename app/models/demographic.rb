require_relative 'codes.rb'

class Demographic < ApplicationRecord

  belongs_to :school

  include Codes

  def category_name
    Codes.demo_code(category)
  end

end
