module CURIC::Rubiny
  class Snippet < UI::Command
    attr_accessor :info, :id

    def initialize(id)
      @id = id
      @info = CURIC::Rubiny.snippets.get_info(@id)
      super(@info['name']) do
        play
      end
    end

    def play
      # the first method to be called when the command is executed
    end

    def play_value(value)
      # the first method to be called when the command is executed
    end
  end
end
