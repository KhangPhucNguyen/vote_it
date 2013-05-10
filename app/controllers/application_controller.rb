class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionHelper
  require 'will_paginate/array'
end
