# Jason's Multihaftetikettierapparat

Todo: Intro

## Architecture
This system provides a REST endpoint to receive structured JSON data and renders configurable ZPL templates it then outputs to a printer, be it local or networked.

### Assumptions
It is assumed that every printer is loaded with one size of label that is not changed. Thus the label format can be part of the printer config.

### Configuration
Every printer is configured through a class that contains everything that is necessary to drive the printer. ZPL templates are created using the [Zebra::Zpl](https://github.com/bbulpett/zebra-zpl) ruby gem.


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

