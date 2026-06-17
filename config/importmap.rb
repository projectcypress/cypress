# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application', preload: true

# Preload core/vendor libs so the browser can fetch them in parallel and avoid waterfall
pin 'jquery2-core', to: 'jquery2.min.js', preload: true
pin 'jquery2', to: 'jquery2_global.js', preload: true
pin '@popperjs/core', to: 'popper.min.js', preload: true # @2.11.8
pin 'bootstrap', to: 'bootstrap.bundle.min.js', preload: true # @5.3.8
pin 'datatables', to: 'datatables.min.js', preload: true
pin 'jquery-ui', to: 'jquery-ui.min.js', preload: true # @1.14.1
pin 'parsleyjs', to: 'parsley/parsley.min.js', preload: true

# Hotwire
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'

# Other libraries
pin 'dragon-drop/dragon-drop', to: 'dragon_drop/dragon-drop.js', preload: true
pin 'assets.core', to: 'assets_framework/assets.core.js'

pin_all_from 'app/javascript/controllers', under: 'controllers'
pin 'local-time' # @3.0.3
