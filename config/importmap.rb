# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application', preload: true
pin 'jquery2-core', to: 'jquery2.min.js' # or whatever file jquery2 currently resolves to in your setup
pin 'jquery2', to: 'jquery2_global.js'
pin '@popperjs/core', to: 'popper.min.js', preload: true # @2.11.8
pin 'bootstrap', to: 'bootstrap.bundle.min.js', preload: true # @5.3.8
pin 'datatables', to: 'datatables.min.js'
pin 'assets.core', to: 'assets_framework/assets.core.js'
pin 'jquery-ui', to: 'jquery-ui.min.js' # @1.14.1
pin 'parsleyjs', to: 'parsley/parsley.min.js'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin 'dragon-drop/dragon-drop', to: 'dragon_drop/dragon-drop.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'
