module CURIC
  module Rubiny
    class << self
      attr_accessor :snippets, :source_files
    end

    @snippets ||= []
    @source_files ||= []

    TEMP = File.join(PATH, 'temp').freeze

    Sketchup.require "#{PATH}/js_loader"

    def self.read_json(file)
      JSON.parse(File.read(file))
    end

    unless file_loaded?(__FILE__)
      JSLoader.show
      file_loaded(__FILE__)
    end
  end
end
