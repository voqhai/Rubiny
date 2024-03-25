module CURIC::Rubiny
  class QuickComponent < Snippet
    def initialize(*args)
      super(*args)
    end

    def play
      UI.messagebox('Quick Component')
    end

    def use_context_menu?
      selection = Sketchup.active_model.selection
      return false if selection.empty?

      true
    end
  end
end
