module CURIC::Rubiny
  class FindFace < Snippet
    def initialize(*args)
      super(*args)
    end

    # get_validation_proc
    def snippet_validation_proc
      proc { Sketchup.active_model.selection.empty? ? MF_GRAYED : MF_ENABLED }
    end
  end
end
