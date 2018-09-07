# The Id model is an extension of app/models/qdm/id.rb as defined by CQM-Models.
module QDM
  class Id
    # TODO: remove Dynamic attributes.  This is only here for supporting 2018.0.1 bundle import functionality.
    include Mongoid::Attributes::Dynamic
  end
end
