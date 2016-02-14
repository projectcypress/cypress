class Hash
  def method_missing(sym)
    if key?(sym.to_s)
      return self[sym.to_s]
    elsif key?(sym)
      self[sym]
    else
      super
    end
  end
end
