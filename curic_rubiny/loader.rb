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

    @debug = true
    def self.debug?
      @debug
    end

    def self.register_snippet(snippet)
      @snippets.add(snippet)
    end

    def self.install(snippet)
      p "Install #{snippet.id}"
      info = snippet.info
      ruby_file = info['ruby_file']
      file = File.join(CURIC::Rubiny::TEMP, ruby_file)
      p "Save to local: #{file}"
      puts info['ruby_content']
    end

    def self.build
      @snippets = Snippets.new
      JSLoader.show
    end

    def self.save_to_temp(file, content)
      path = File.join(CURIC::Rubiny::TEMP, file)
      File.open(path, 'w') { |f| f.write(content) }
    end

    unless file_loaded?(__FILE__)
      build
      file_loaded(__FILE__)
    end
  end
end
