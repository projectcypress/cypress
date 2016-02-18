require 'render_anywhere'

module Cypress
  class PdfReport
    include RenderAnywhere

    def initialize(product)
      @product = product
      set_render_anywhere_helpers(ProductsHelper)
      set_render_anywhere_helpers(FilteringTestsHelper)
    end

    def build_html
      @html = render(template: 'products/report.html.erb',
                     layout: false,
                     locals: { :@product => @product })
      @html
    end

    def download_pdf
      build_html

      pdf = PDFKit.new(@html, footer_right: 'page [page] of [topage]',
                              outline: true,
                              margin_top: 20,
                              margin_bottom: 20,
                              margin_left: 20,
                              margin_right: 20,
                              header_font_size: 18,
                              header_spacing: 4,
                              header_left: 'cypress v3',
                              header_line: true,
                              footer_font_size: 10,
                              footer_spacing: 4,
                              footer_left: @product.name.to_s,
                              footer_center: '[section]',
                              footer_line: true)

      pdf
    end
  end
end
