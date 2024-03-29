module CURIC::Rubiny
  class Snippet # < UI::Command
    def self.class_name(id)
      id.split('_').map(&:capitalize).join
    end

    def self.const(id)
      name = class_name(id)
      return CURIC::Rubiny.const_get(name) if CURIC::Rubiny.const_defined?(name)

      nil
    end

    attr_accessor :info, :id, :name
    attr_writer :installed
    attr_accessor :command

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
      @evaluated = false
      @loaded = false

      @command = UI::Command.new(@name) do
        play
      end

      @command.small_icon = CURIC::Rubiny::ICON
      @command.large_icon = CURIC::Rubiny::ICON

      @command.tooltip = @info['description']
      @command.status_bar_text = @info['description']

      validate = snippet_validation_proc
      @command.set_validation_proc(&validate) if validate
    end

    def installed?
      @installed
    end

    def info
      i = @info.dup
      i['installed'] = installed?
      i['loaded'] = @loaded
      i['evaluated'] = @evaluated

      @shortcut ||= get_shortcut
      i['shortcut'] = @shortcut

      i
    end

    def check_installed
      ruby_file = @info['ruby_file']
      return false unless ruby_file

      full_path = File.join(LOCAL_DIR, ruby_file)

      self.installed = File.exist?(full_path)

      installed?
    end

    def play
      # the first method to be called when the command is executed
    end

    def play_value(value)
      # the first method to be called when the command is executed
    end

    def get_value
      #
    end

    def context_menu(context_menu)
      return unless use_context_menu?

      context_menu.add_item(@command)
    end

    def use_context_menu?
      false
    end

    def snippet_validation_proc
      nil
    end

    def hover_changed(value)
      nil
    end

    def get_shortcut
      cmd = "Rubiny/Snippets/#{@name}"
      shortcut_info = Sketchup.get_shortcuts.find { |s| s.include?(cmd) }
      return unless shortcut_info

      # Split at "\t" and get the key at the first index
      shortcut_info.split("\t")[0]
    end
  end
end
