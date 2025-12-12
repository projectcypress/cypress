module AssetsHelper
  def inline_stylesheet(logical_name = "application")
    css = read_css_asset(logical_name)
    return "" if css.blank?
    # tag.style comes from ActionView; wraps content with <style type="text/css">…</style>
    tag.style(css, type: "text/css")
  end

  private

  def read_css_asset(logical_name)
    logical_path = logical_name.to_s
    logical_path += ".css" unless logical_path.end_with?(".css")

    # 1) Try the digested asset path in public/assets (production or after precompile)
    begin
      asset_url = asset_path(logical_path) # e.g., /assets/application-abc123.css or /assets/application.css
      if asset_url.present?
        # remove host if asset_host is set
        path_only = asset_url.sub(%r{\Ahttps?://[^/]+}, "")
        if path_only.start_with?("/assets/")
          public_path = Rails.root.join("public", path_only.delete_prefix("/"))
          return File.read(public_path) if File.exist?(public_path)
        end
      end
    rescue => _
      # asset_path can raise if the asset isn't known; ignore and fall back
    end

    # 2) Fall back to searching asset load paths (dev/test, or when using cssbundling)
    Rails.application.config.assets.paths.each do |load_path|
      candidate = File.join(load_path, logical_path)
      return File.read(candidate) if File.exist?(candidate)
    end

    nil
  end
end