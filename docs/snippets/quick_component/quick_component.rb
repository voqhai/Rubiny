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

    unless CURIC::Rubiny.snippets.find_by_id(@@id)
      snippet = QuickComponent.new
      CURIC::Rubiny.register_snippet(snippet)
    end
  end
end
