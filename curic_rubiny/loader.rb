module CURIC
  module Rubiny
    Sketchup.require "#{PATH}/js_loader"

    unless file_loaded?(__FILE__)
      JSLoader.show
      file_loaded(file)
    end
  end
end
