class ApplicationController < ActionController::Base
  def cast_boolean_param(name)
    params[name] = ActiveModel::Type::Boolean.new.cast(params[name])
  end
end
