class String
  def to_boolean
    %w[1 true t].include?(downcase)
  end
end
