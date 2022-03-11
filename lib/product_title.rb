module Multihaftetikettierapparat
  class ProductTitle
    attr_accessor :truncated, :font_size

    FONT_SIZES = {
      0..14 => Zebra::Zpl::FontSize::SIZE_5,
      15..21 => Zebra::Zpl::FontSize::SIZE_4,
      22..28 => Zebra::Zpl::FontSize::SIZE_2,
      29..35 => Zebra::Zpl::FontSize::SIZE_1,
    }

    def initialize(origin)
      @truncated = origin[0..34]
    end

    def font_size
      FONT_SIZES.find { |k, v| break v if k.cover? @truncated.length }
    end
  end
end