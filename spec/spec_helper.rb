$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require "buzzsaw"
require "thread_safe"
require 'smelter'
require 'redis-objects'
require "rspec"

$LOAD_PATH.unshift File.expand_path('../../spec/support', __FILE__)
