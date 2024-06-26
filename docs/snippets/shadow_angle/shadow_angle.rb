module CURIC::Rubiny
  class ShadowAngle < Snippet
    def initialize(*args)
      super(*args)
    end

    def play
      UI.messagebox("Play #{info['name']}")
    end

    def play_value(value)
      p "Run Shadow Angle with value: #{value}"
      Sketchup.active_model.shadow_info['NorthAngle'] = value.to_f
    end

    def get_value
      Sketchup.active_model.shadow_info['NorthAngle']
    end

    def hover_changed(hover)
      return unless PLUGIN.debug?

      p "Hover changed: #{hover}"
      if hover
        p "show preview shadow angle"
      else
        p "hide preview shadow angle"
      end
    end
  end
end
