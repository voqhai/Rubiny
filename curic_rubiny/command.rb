module CURIC::Rubiny
  class Snippet < UI::Command
    attr_accessor :info, :id, :name
    attr_writer :installed

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

      @installed = false

      super(@name) do
        play
      end

      self.small_icon = File.join(PATH_R, ICON_EX)
      self.large_icon = File.join(PATH_R, ICON_EX)

      self.tooltip = @info['description']
      self.status_bar_text = @info['description']
    end

    def installed?
      @installed
    end

    def play
      # the first method to be called when the command is executed
    end

    def play_value(value)
      # the first method to be called when the command is executed
    end

    def context_menu(context_menu)
      return unless use_context_menu?

      context_menu.add_item(self)
    end

    def use_context_menu?
      false
    end
  end
end
