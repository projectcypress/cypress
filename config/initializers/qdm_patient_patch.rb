# Monkey-patch QdmPatient#render to humanize ISO8601 date strings
require 'time'

QdmPatient.class_eval do
  alias_method :render_original, :render

  def render(*args)
    html = render_original(*args)
    html.to_s.gsub(/(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+\-]\d{2}:\d{2}))/) do |iso|
      t = Time.parse(iso).in_time_zone
      t.strftime('%B %e, %Y %l:%M%P')
    end.html_safe
  end
end
