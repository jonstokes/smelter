$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require "thread_safe"
require 'smelter'
require 'redis-objects'
require "rspec"

load 'spec/support/test_classes.rb'
