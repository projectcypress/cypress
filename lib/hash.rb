class Hash
  def method_missing(sym)
    if self.key?(sym.to_s)
      return self[sym.to_s]
    elsif self.key?(sym)
      self[sym]
    else
      super
    end
  end
end
