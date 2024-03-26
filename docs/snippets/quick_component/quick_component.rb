module CURIC::Rubiny
  class QuickComponent < Snippet
    def initialize(*args)
      super(*args)

      @settings_section = PLUGIN_NAME + "_#{@id}_settings"
    end

    def play
      model = Sketchup.active_model
      selection = model.selection

      # remove locked entities
      selection = selection.reject { |e| e.locked? }
      return if selection.empty?

      model.start_operation('Quick Component', true)
      # create group
      group = model.active_entities.add_group(selection)

      # create component
      component = group.to_component
      component.definition.name = defalt_name

      model.commit_operation

      # clear selection
      model.selection.clear
      model.selection.add(component)
    end

    def use_context_menu?
      selection = Sketchup.active_model.selection
      return false if selection.empty?

      true
    end

    def defalt_name
      Sketchup.read_default(@settings_section, 'default_name', 'Object')
    end

    def show_settings
      r = UI.inputbox(['Prefix'], [defalt_name], "#{@info['name']} Settings")
      return unless r

      v = r[0]
      # Validate input
      UI.messagebox('Invalid input') if v.strip.empty?

      # Too short
      UI.messagebox('Input too short') if v.length < 3

      Sketchup.write_default(@settings_section, 'default_name', v)
    end
  end
end
