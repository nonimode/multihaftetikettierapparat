# frozen_string_literal: true
require "zebra/zpl"
require "net/http"

module Multihaftetikettierapparat
  # config options for the printer, with some defaults set.
  class PrinterConfig
    attr_accessor :human_readable_name,
                  :machine_name,
                  :location,
                  :label_width,
                  :label_height,
                  :print_density,
                  :print_speed,
                  :host,
                  :print_service

    def initialize
      @print_speed   = 3
      @host          = "localhost"
      @print_service = "lp"
    end

    def expose
      {
        human_readable_name: human_readable_name,
        location: location
      }
    end
  end

  # just a wrapper for the zebra-zpl class, to provide easier access to the generated ZPL source
  class Label < Zebra::Zpl::Label
    def initialize(config)
      super(
        width: config.label_width,
        length: config.label_height,
        print_speed: config.print_speed
      )
    end

    def to_zpl
      zpl = +""
      dump_contents(zpl)
      zpl
    end
  end

  class Printer
    attr_accessor :config, :label

    def configure
      @config ||= Multihaftetikettierapparat::PrinterConfig.new
      yield(config)
    end

    def width_inch
      (config.label_width.to_f / config.print_density).round(2)
    end

    def height_inch
      (config.label_height.to_f / config.print_density).round(2)
    end

    def print_density_dpmm
      (config.print_density / 25.4).round
    end

    def preview
      uri = URI "http://api.labelary.com/v1/printers/#{print_density_dpmm}dpmm/labels/#{width_inch}x#{height_inch}/0/"
      http = Net::HTTP.new uri.host, uri.port
      request = Net::HTTP::Post.new uri.request_uri
      request.body = @label.to_zpl
      response = http.request request

      raise Error if response.class.name != "Net::HTTPOK"

      response.body
    end

    def print(copies = 1)
      @label.copies = copies
      # tear-off labels
      @label << Zebra::Zpl::Raw.new(
        data: "^MMT",
        position: [50, 50]
      )
      print_job = Zebra::PrintJob.new config.machine_name
      print_job.print @label, config.host, print_service: config.print_service
    end
  end
end
