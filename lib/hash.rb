class Hash
  def method_missing(sym)
    if key?(sym.to_s)
      self[sym.to_s]
    elsif key?(sym)
      self[sym]
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    super
  end
end
