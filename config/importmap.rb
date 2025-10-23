# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "jquery2" # @2.0.3
pin "turbolinks" # @5.2.0
pin "@popperjs/core", to: "extensions/@popperjs--core.js", preload: true # @2.11.8
pin "bootstrap", to: 'extensions/bootstrap.bundle.min.js', preload: true # @5.3.8
pin "cypress", to: "extensions/cypress.js"
