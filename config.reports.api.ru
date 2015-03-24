require 'rubygems'
require 'bundler'
Bundler.require

require './ReportSystem/report_system_api'

run ReportSystemAPI.new
