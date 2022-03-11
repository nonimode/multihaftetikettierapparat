require './lib/printer'
require './lib/product_title'
require './templates/ean13'
require './templates/code128'
require 'sinatra'
require 'sinatra/cross_origin'
require 'barby/barcode/ean_13'

class MHEA < Sinatra::Base
  printers = {}

  printers[:zebra_lager] = Multihaftetikettierapparat::Printer.new
  printers[:zebra_lager].configure do |config|
    config.label_width = 455
    config.label_height = 255
    config.print_density = 203
    config.human_readable_name = 'Zebra QLn420'
    config.machine_name = 'Zebra_Technologies_ZTC_QLn420__CPCL_'
    config.location = "Lager"
    config.print_speed = 14
  end
  
  printers[:zebra_leo] = Multihaftetikettierapparat::Printer.new
  printers[:zebra_leo].configure do |config|
    config.label_width = 455
    config.label_height = 255
    config.print_density = 203
    config.human_readable_name = 'Zebra QLn420'
    config.machine_name = 'Zebra_MBP'
    config.location = "Leo's Büro"
    config.print_speed = 1
  end
  
  printers[:zd421_01] = Multihaftetikettierapparat::Printer.new
  printers[:zd421_01].configure do |config|
    config.label_width = 455
    config.label_height = 255
    config.print_density = 203
    config.human_readable_name = 'Zebra ZD421'
    config.machine_name = 'ZD421_01'
    config.location = "Leo's Büro"
    config.print_speed = 5
  end

  configure do
    enable :cross_origin
  end

  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

  options "*" do
    response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
    response.headers["Access-Control-Allow-Origin"] = "*"
    200
  end

  get '/printers' do
    content_type :json
    return_json = {
      printers: []
    }
    printers.each do |key, printer|
      printer_info = printer.config.expose
      printer_info[:id] = key
      return_json[:printers] << printer_info
    end
    return_json.to_json
  end

  post %r{/(print|preview)/([\w]+)/?([0-9]+)?} do |action, printer, quantity|
    begin
      json_payload = JSON.parse(request.body.read, symbolize_names: true)

      halt(400, "No barcode given") if json_payload[:barcode].nil?

      if json_payload[:barcode].to_s.match(/\d{13}/)
        parsed_barcode = Barby::EAN13.new(json_payload[:barcode].to_s[0..11])
        printers[printer.to_sym].label = if parsed_barcode.data_with_checksum == json_payload[:barcode].to_s
          EAN13.new(printers[printer.to_sym].config, json_payload)
        else
          Code128.new(printers[printer.to_sym].config, json_payload)
        end
      else
        printers[printer.to_sym].label = Code128.new(printers[printer.to_sym].config, json_payload)
      end

      case action
      when "print"
        printers[printer.to_sym].print(quantity.nil? ? 1 : quantity)
      when "preview"
        content_type :png
        printers[printer.to_sym].preview
      end
    rescue JSON::ParserError
      halt 400, "JSON format error"
    end
  end
end
