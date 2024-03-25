module CURIC::Rubiny
  class Snippet < UI::Command
    attr_accessor :info, :id, :name

    DEFAULT_PROPERTIES = {
      'name' => 'Snippet',
      'description' => 'A snippet'
    }

    def initialize(props)
      raise 'arg must be a Hash' unless props.is_a?(Hash)

      props = DEFAULT_PROPERTIES.merge(props)

      @info = props
      @id = @info['id']
      @name = @info['name']

      super(@name) do
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
