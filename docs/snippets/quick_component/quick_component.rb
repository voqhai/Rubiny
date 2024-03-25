module CURIC::Rubiny
  class QuickComponent < Snippet
    def initialize(*args)
      super(*args)
    end

    def play
      UI.messagebox('Quick Component')
    end
  end
end
