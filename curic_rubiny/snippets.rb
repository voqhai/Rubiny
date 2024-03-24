module CURIC::Rubiny
  class Snippets
    include Enumerable
    attr_reader :snippets
    attr_accessor :database

    def initialize
      @database = {}
      @snippets = []
    end

    def each(&block)
      @snippets.each(&block)
    end

    def [](index)
      @snippets[index]
    end

    def get_info(id)
      @database[id]
    end

    def find_by_id(id)
      @snippets.find { |snippet| snippet.id == id }
    end

    def add(snippet)
      raise 'Snippet must be a subclass of Snippet' unless snippet.is_a?(Snippet)
      raise 'Duplicate snippet id' if find_by_id(snippet.id)

      @snippets << snippet
    end
  end
end
