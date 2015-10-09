cp ./.travis/mongoid.yml ./config/mongoid.yml
rubocop
bundle exec rake test
