# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "jquery2" # @2.0.3
pin "turbolinks" # @5.2.0
pin "bootstrap" # @5.3.8
pin "@popperjs/core", to: "@popperjs--core.js" # @2.11.8
pin "breadcrumb", to: "extensions/breadcrumb.js"