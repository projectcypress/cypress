module StatusFormatHelper
  @@status_lookup = {"pass" => "passing", "fail" => "failing"}

  def format_status(status)
    @@status_lookup[status] ? @@status_lookup[status] : status
  end
end
