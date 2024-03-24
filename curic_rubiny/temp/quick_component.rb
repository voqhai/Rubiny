module CURIC::Rubiny
  class QuickComponent < Snippet
    attr_accessor :info, :id

    def initialize
      @id = File.basename(__FILE__, '.*')
      json = File.join(File.dirname(__FILE__), "#{@id}.json")
      @info = CURIC::Rubiny.read_json(json)
      super(@info['name'], &proc { run })
    end

    def run
      create
    end

    def create
      UI.messagebox('Quick Component')
    end
  end

  unless file_loaded?(__FILE__)
    cmd = QuickComponent.new
    CURIC::Rubiny.snippets << cmd

    file_loaded(__FILE__)
  end
end
