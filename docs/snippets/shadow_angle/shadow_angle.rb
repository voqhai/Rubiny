module CURIC::Rubiny
  class ShadowAngle < Snippet
    def initialize(**args)
      super(args)
    end

    def play
      p 'Run Shadow Angle'
    end

    def play_value(value)
      p "Run Shadow Angle with value: #{value}"
    end

    # CURIC::Rubiny.register_snippet(new) unless CURIC::Rubiny.snippets.find_by_id(@@id)
  end
end
