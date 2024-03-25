module CURIC::Rubiny
  class QuickComponent < Snippet
    @@id = 'quick_component'
    def initialize
      super(@@id)

      # Define some instance variables
      @model = Sketchup.active_model
    end

    def play
      UI.messagebox('Quick Component')
    end

    CURIC::Rubiny.register_snippet(new) unless CURIC::Rubiny.snippets.find_by_id(@@id)
  end
end
