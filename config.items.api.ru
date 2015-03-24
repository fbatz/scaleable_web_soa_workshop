require 'rubygems'
require 'bundler'
Bundler.require

require './ItemTracking/item_tracking_api'

run ItemTrackingAPI.new
