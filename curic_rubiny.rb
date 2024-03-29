require 'sketchup.rb'
require 'extensions.rb'
module CURIC
  module Rubiny
    PLUGIN = self
    PLUGIN_NAMESPACE  = 'Curic'.freeze
    PLUGIN_ID         = 'Rubiny'.freeze
    PLUGIN_NAME       = "#{PLUGIN_NAMESPACE} #{PLUGIN_ID}".freeze

    FILENAMESPACE = File.basename(__FILE__, '.*')
    PATH_ROOT     = File.dirname(__FILE__).freeze
    PATH          = File.join(PATH_ROOT, FILENAMESPACE).freeze

    unless file_loaded?(__FILE__)
      ex = SketchupExtension.new(PLUGIN_NAME, "#{PATH}/loader")
      ex.description = 'Rubiny is a collection of Ruby snippets for SketchUp.'
      ex.version     = '0.0.4'
      ex.creator     = 'Curic'
      Sketchup.register_extension(ex, true)
      PLUGIN_EX = ex
    end
  end
end
