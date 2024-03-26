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
      if index.is_a?(Integer)
        @snippets[index]
      elsif index.is_a?(String)
        find_by_id(index)
      else
        raise 'Invalid index type'
      end
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

    def remove(snippet)
      if snippet.is_a?(Snippet)
        #
      elsif snippet.is_a?(String)
        snippet = find_by_id(snippet)
      else
        raise 'Invalid snippet type'
      end

      @snippets.delete(snippet)
    end

    def create(info)
      snippet = self.find_by_id(info['id'])
      return snippet if snippet
      return unless info['ruby_file'] && info['ruby_content']

      eval(info['ruby_content'])

      const = Snippet.const(id)
      return unless const

      snippet = const.new(info)

      add(snippet)

      snippet
    rescue => e
      # Something wrong with snippet
      puts e
      nil
    end

    def build_context_menu(context_menu)
      sub_menu = context_menu.add_submenu(PLUGIN_ID)
      @snippets.each do |snippet|
        snippet.context_menu(sub_menu)
      end
    end

  end
end
