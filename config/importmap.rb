# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "jquery2" # @2.0.3
pin "turbolinks" # @5.2.0
pin "@popperjs/core", to: "extensions/@popperjs--core.js", preload: true # @2.11.8
pin "bootstrap", to: 'extensions/bootstrap.bundle.js', preload: true # @5.3.8
pin "cypress", to: "extensions/cypress.js"
pin "datatables", to: "extensions/datatables.min.js"
pin "assets.core", to: "extensions/assets_framework/assets.core.js"
# pin "jquery-ui/widgets/autocomplete", to: "extensions/jquery-ui.js" # @1.14.1
pin "jquery-ui", to: "extensions/jquery-ui.js" # @1.14.1
pin "parsleyjs", to: "extensions/parsley/parsley.js"
pin "jasny-bootstrap", to: "jasny-bootstrap.min.js"
# pin "jquery-ui/widgets/accordion", to: "extensions/jquery-ui.js" # @1.14.1
# pin "jquery-ui/widgets/button", to: "extensions/jquery-ui.js" # @1.14.1
# pin "jquery-ui/widgets/dialog", to: "extensions/jquery-ui.js" # @1.14.1
# pin "jquery-ui/widgets/menu", to: "extensions/jquery-ui.js" # @1.14.1
# pin "jquery-ui/widgets/progressbar", to: "extensions/jquery-ui.js" # @1.14.1
# pin "jquery-ui/widgets/slider", to: "extensions/jquery-ui.js" # @1.14.1
# pin "jquery-ui/widgets/spinner", to: "extensions/jquery-ui.js" # @1.14.1
# pin "jquery-ui/widgets/tooltip", to: "extensions/jquery-ui.js" # @1.14.1
# pin "jquery-ui/widgets/datepicker", to: "extensions/jquery-ui.js" # @1.14.1
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
