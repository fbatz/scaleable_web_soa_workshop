require 'rubygems'
require 'bundler'
Bundler.require

require './LocationManagement/location_management_api'

run LocationManagementAPI.new
