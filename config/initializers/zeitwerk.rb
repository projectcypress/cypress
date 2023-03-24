# config/initializers/zeitwerk.rb
Rails.autoloaders.each do |autoloader|
  autoloader.collapse(Rails.root.join("lib/ext"))
  autoloader.collapse(Rails.root.join("lib/cypress/highlighting"))
end
