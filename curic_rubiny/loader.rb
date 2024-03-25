module CURIC
  module Rubiny
    class << self
      attr_accessor :snippets, :source_files, :debug, :local_snippets
    end

    @source_files ||= []

    LOCAL_DIR = File.join(PATH, 'local').freeze

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
      file = File.join(CURIC::Rubiny::LOCAL_DIR, ruby_file)

      dir = File.dirname(file)
      FileUtils.mkdir_p(dir) unless File.directory?(dir)

      save_to_temp(file, info['ruby_content'])

      json_file = File.join(dir, "#{snippet.id}.json")
      data = info.dup
      data.delete('ruby_content')
      save_to_temp(json_file, JSON.pretty_generate(data))
    end

    def self.remove(id)
      # p "Remove #{id}"
    end

    def self.update(id)
      # p "Update #{id}"
    end

    def self.build
      @snippets = Snippets.new
      JSLoader.show
    end

    def self.save_to_temp(file, content)
      File.open(file, 'w') { |f| f.write(content) }
    end

    unless file_loaded?(__FILE__)
      build
      file_loaded(__FILE__)
    end
  end
end
