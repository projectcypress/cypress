# frozen_string_literal: true

module Cypress
  class MbiGenerator
    # 2, 5, 8, and 9 characters are always letters
    # 1, 4, 7, 10, and 11 characters are always numbers
    # The 3rd and 6th characters are letters or numbers.
    # CMS doesnt use dashes in the MBI.
    # Position 1 is numeric values 1 thru 9
    def self.generate
      # cv - Numeric values 1 thru 9
      cv = %w[1 2 3 4 5 6 7 8 9].sample(1)
      # nv - Numeric values 0 thru 9
      nv = %w[0 1 2 3 4 5 6 7 8 9].sample(5)
      # av - Alphabetic values A thru Z (minus B, I, L, O, S, Z)
      av = %w[a c d e f g h j k m n p q r t u v w x y].sample(5)

      "#{cv[0]}#{av[0]}#{av[1]}#{nv[0]}#{av[2]}#{nv[1]}#{nv[2]}#{av[3]}#{av[4]}#{nv[3]}#{nv[4]}".upcase
    end
  end
end
