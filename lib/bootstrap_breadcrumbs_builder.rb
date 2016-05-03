# The BootstrapBreadcrumbsBuilder is a Bootstrap compatible breadcrumb builder.
# It provides basic functionalities to render a breadcrumb navigation according to Bootstrap's conventions.
#
# Originally from https://gist.github.com/riyad/1933884/ modified for Bootstrap 3 and
# "Go to hell with separator, use Css Dumbass" policy
#
# You can use it with the :builder option on render_breadcrumbs:
#     <%= render_breadcrumbs :builder => ::BootstrapBreadcrumbsBuilder" %>
#
# via https://gist.github.com/equivalent/9972557

class BootstrapBreadcrumbsBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder
  NoBreadcrumbsPassed = Class.new(StandardError)

  def render
    regular_elements = @elements.dup
    active_element = regular_elements.pop || raise(NoBreadcrumbsPassed)

    @context.content_tag(:ol, class: 'breadcrumb') do
      regular_elements.collect do |element|
        render_regular_element(element)
      end.join.html_safe + render_active_element(active_element).html_safe
    end
  end

  def render_regular_element(element)
    @context.content_tag :li do
      @context.link_to(compute_name(element), compute_path(element), element.options)
    end
  end

  def render_active_element(element)
    @context.content_tag :li, class: 'active' do
      compute_name(element)
    end
  end
end
