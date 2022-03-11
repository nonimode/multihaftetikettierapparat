class Code128 < Multihaftetikettierapparat::Label
  attr_accessor :label

  def initialize(printer_config, json_payload)
      @label = super(printer_config)

      text_left_margin = 25

      barcode = json_payload[:barcode]

      # https://stackoverflow.com/questions/22474293/zpl-how-to-center-barcode-code-128
      # the 26 is 13 dots for start/stop codes, the 2 is the narrow bar width
      barcode_width = (json_payload[:barcode].length * 11 + 26) * 2
      barcode_margin = ((printer_config.label_width - barcode_width).to_f / 2).round
      # I hope this works

      if barcode_width < printer_config.label_width
        @label << Zebra::Zpl::Barcode.new(
          data:                       json_payload[:barcode],
          position:                   [barcode_margin, 170],
          height:                     50,
          print_human_readable_code:  true,
          narrow_bar_width:           2,
          type:                       Zebra::Zpl::BarcodeType::CODE_128_AUTO
        )
      else
        @label << Zebra::Zpl::Text.new( 
          data:      '--- Barcode too long ---',
          position:  [text_left_margin, 170],
          font_size: Zebra::Zpl::FontSize::SIZE_3,
          width:     350,
          max_lines: 1
        )
      end

      title = Multihaftetikettierapparat::ProductTitle.new(json_payload[:product_title])

      @label << Zebra::Zpl::Text.new( 
        data:      title.truncated || '',
        position:  [text_left_margin, 25],
        font_size: title.font_size,
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
        position: [100, 80],
        font_size: Zebra::Zpl::FontSize::SIZE_1,
        width: 350,
        max_lines: 3,
        justification: Zebra::Zpl::Justification::RIGHT
      )

      @label << Zebra::Zpl::Text.new( 
        data: json_payload[:size] || '',
        position: [150, 25],
        font_size: Zebra::Zpl::FontSize::SIZE_5,
        width: 300,
        max_lines: 1,
        justification: Zebra::Zpl::Justification::RIGHT
      )
  end
end 