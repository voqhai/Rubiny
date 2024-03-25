module CURIC::Rubiny
  class ShadowAngle < Snippet
    def initialize(**args)
      p 'Shadow Angle.initialize'
      ap args
      super(args)
    end

    def play
      p 'Run Shadow Angle'
    end

    def play_value(value)
      p "Run Shadow Angle with value: #{value}"
    end
  end
end
