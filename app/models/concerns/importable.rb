# Adds an `importing` flag to models, which can be used to e.g. skip validations.
module Importable
  include ActiveSupport::Concern

  attr_accessor :importing
end
