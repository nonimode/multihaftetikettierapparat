# Multihaftetikettierapparat
This piece of code is an adapter between JSON data posted to an HTTP endpoint and a (networked) Zebra label printer.

This piece is glue code all the way down, with configuration intertwined with code. I am aware it's not beautiful, but it gets the job done.

## Architecture
This system provides a REST endpoint to receive structured JSON data and renders configurable ZPL templates it then outputs to a printer, be it local or networked.

## Caveats
Obviously this system is meant to be run in a local network. I assume no responsibility whatsoever for any damage it may cause.

### Assumptions
It is assumed that every printer is loaded with one size of label that is not changed. Thus the label format can be part of the printer config.

### Setup
I have setup a Linux VM with Phusion Passenger, closely following their [tutorial](https://www.phusionpassenger.com/docs/tutorials/deploy_to_production/installations/oss/ownserver/ruby/nginx/).

You need to have a valid SSL certificate for your server, otherwise cross-domain requests will be blocked by the browser.

I installed cups via APT and added the printers as RAW ZPL devices. But attaching a CUPS server running on a different machine will probably work just as well.

To run it locally on you machine install the bundle and then issue `bundle exec passenger start` which should give you a working http server on `localhost:3000`.

### Configuration
Every printer is configured through a class that contains everything that is necessary to drive the printer. ZPL templates are created using the [Zebra::Zpl](https://github.com/bbulpett/zebra-zpl) ruby gem. See [multihaftetikettierapparat.rb] for the structure of the `printers{}` hash:

```ruby
printers[:zd421_01] = Multihaftetikettierapparat::Printer.new
printers[:zd421_01].configure do |config|
  config.label_width = 455 # label width in dots
  config.label_height = 255 # label height in dots
  config.print_density = 203 # printer resolution in dpi
  config.human_readable_name = 'Zebra ZD421' # arbitrary
  config.machine_name = 'ZD421_01' # the cups printer name
  config.location = "Leo's Büro" # arbitrary
  config.print_speed = 5 # set to your liking, range 1-14
end
```

### List of configured printers
The system provides a JSON endpoint `/printers` that provides information on the printers that are known to the system.

Sample data structure:
```json
{
  "printers": [
    {
      "human_readable_name": "Zebra QLn420",
      "id": "zebra-qln420",
      "location": "Main Warehouse"
    },
    {
      "human_readable_name": "Dymo Thingy",
      "id": "dymo-thingy",
      "location": "Office"
    }
  ]
}
```
With this data a printer selector can be created, the id corresponds to the printer_id in the _Printing_ section.

### Previewing/Printing
Sample data structure:
```json
{
  "barcode": 4063746008132,
  "product_title": "My awesome product",
  "product_type": "Product's type",
  "size": "Grand",
  "options": ["Color: Blue", "Material: Space Stuff"]
}
```

When sent to the printers _print_ url `http://localhost:4567/print/{printer_id}/{optional quantity, defaults to 1}` the system converts the data structure to ZPL an sends it to the printer specified in the URL, it answers with HTTP 200 when everything is OK, and with HTTP 400 otherwise.

When sent to the printers _preview_ url `http://localhost:4567/preview/{printer_id}` the system converts the data structure to ZPL an sends it to [Labelary](http://labelary.com) to get a PNG representation of the label. It returns a PNG if all went well, and a HTTP 400 otherwise.

## Why?
We use Shopify as our online shop system, and they endorsed Dymo Printers, we thus bought several Dymo Labelwriter 450. Dymo provided a tray program and a [Javascript SDK](https://github.com/dymosoftware/dymo-connect-framework) which worked fine for some time. But since a Chrome update updated the CORS policy and thus would not communicate with the tray program anymore the whole thing broke. The [issue](https://github.com/dymosoftware/dymo-connect-framework/issues/30) has been known for almost six months now and there is still no solution. What's more, they completely 'revamped' their label creation software to utter uselessness and provide the tray program only for Windows. I use a Mac.

On a whim I tried creating ZPL and sending it to a Zebra printer I had, and it was a way more pleasant experience.

## What's with the name?
The German language knows a thing call compound nouns, and this is an example of that. It means "Device (Apparatus) to facilitate a multitude of sticky labeling operations".
