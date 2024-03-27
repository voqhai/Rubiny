module CURIC::Rubiny
  class DialogCenterScreen < Snippet
    def initialize(*args)
      super(*args)
    end

    def play
      ObjectSpace.each_object(UI::HtmlDialog) do |dialog|
        dialog.center if dialog.visible?
      end
    end
  end
end
