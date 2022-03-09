class EAN13 < Multihaftetikettierapparat::Label
  attr_accessor :label

  def initialize(printer_config, json_payload)
      @label = super(printer_config)

      text_left_margin = 130

      @label << Zebra::Zpl::Barcode.new(
        data:                       json_payload[:barcode],
        position:                   [45, 40],
        height:                     60,
        print_human_readable_code:  true,
        narrow_bar_width:           2,
        wide_bar_width:             4,
        type:                       Zebra::Zpl::BarcodeType::CODE_EAN13,
        rotation:                   Zebra::Zpl::Rotation::DEGREES_90
      )

      @label << Zebra::Zpl::Text.new( 
        data:      json_payload[:product_title] || '', # ToDo Truncate string to avoid overflow
        position:  [text_left_margin, 25],
        font_size: Zebra::Zpl::FontSize::SIZE_5,
        width:     350,
        max_lines: 1
      )

      @label << Zebra::Zpl::Text.new( 
        data: json_payload[:product_type] || '',
        position: [text_left_margin, 75],
        font_size: Zebra::Zpl::FontSize::SIZE_4,
        width: 350,
        max_lines: 1
      )

      @label << Zebra::Zpl::Text.new( 
        data: json_payload[:sku] || '',
        position: [text_left_margin, 115],
        font_size: Zebra::Zpl::FontSize::SIZE_4,
        width: 350,
        max_lines: 1
      )

      @label << Zebra::Zpl::Text.new( 
        data: json_payload[:options]&.join('\&') || '',
        position: [text_left_margin, 170],
        font_size: Zebra::Zpl::FontSize::SIZE_1,
        width: 350,
        max_lines: 3
      )

      @label << Zebra::Zpl::Text.new( 
        data: json_payload[:size] || '',
        position: [150, 200],
        font_size: Zebra::Zpl::FontSize::SIZE_5,
        width: 300,
        max_lines: 1,
        justification: Zebra::Zpl::Justification::RIGHT
      )
  end
end 