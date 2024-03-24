module CURIC::Rubiny
  class Snippet < UI::Command
    attr_accessor :info, :id

    def initialize(id)
      @id = id
      @info = CURIC::Rubiny.snippets.get_info(@id)
      p "@id: #{@id}"
      ap @info

      super(@info['name']) do
        run
      end
    end
  end
end
