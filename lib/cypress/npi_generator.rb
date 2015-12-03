class NpiGenerator
  def self.generate
    random_number = rand.to_s[2..9]
    random_number = '1' + random_number
    check_digit = checksum('80840' + random_number)
    random_number + check_digit.to_s
  end

  def self.checksum(number)
    digits = number.to_s.reverse.scan(/\d/).map(&:to_i)
    digits = digits.each_with_index.map do |d, i|
      d *= 2 if i.even?
      d > 9 ? d - 9 : d
    end
    sum = digits.inject(0) { |a, e| a + e }
    mod = 10 - sum % 10
    mod == 10 ? 0 : mod
  end
end
