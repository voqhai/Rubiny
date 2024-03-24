module CURIC
  module Rubiny
    class << self
      attr_accessor :snippets, :source_files, :debug
    end

    @source_files ||= []

    TEMP = File.join(PATH, 'temp').freeze

    Sketchup.require "#{PATH}/js_loader"
    Sketchup.require "#{PATH}/command"
    Sketchup.require "#{PATH}/snippets"

    def self.read_json(file)
      JSON.parse(File.read(file))
    end

    @debug = false
    def self.debug?
      @debug
    end

    def self.register_snippet(snippet)
      @snippets.add(snippet)
    end

    def self.build
      @snippets = Snippets.new
      JSLoader.show
    end

    unless file_loaded?(__FILE__)
      build
      file_loaded(__FILE__)
    end
  end
end
