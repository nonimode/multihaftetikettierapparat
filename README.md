# Jason's Multihaftetikettierapparat

Todo: Intro

## Architecture
This system provides a REST endpoint to receive structured JSON data and renders configurable ZPL templates it then outputs to a printer, be it local or networked.

### Assumptions
It is assumed that every printer is loaded with one size of label that is not changed. Thus the label format can be part of the printer config.

### Configuration
Every printer is configured through a class that contains everything that is necessary to drive the printer. ZPL templates are created using the [Zebra::Zpl](https://github.com/bbulpett/zebra-zpl) ruby gem.

### Printing
Sample data structure:
```json
{
  "quantity": 1,
  "data": {
    "barcode": 4063746008132,
    "product_title": "My awesome product",
    "product_type": "Product's type",
    "size": "Grand",
    "options": ["Color: Blue", "Material: Space Stuff"]
  }
}
```

The system converts the data structure to ZPL an sends it to the printer specified in the URL, it answers with HTTP 200 when everything is OK, and with HTTP 400 otherwise.

### List of configured printers
The system provides a JSON endpoint `/printers` that provides information on the printers that are known to the system.

Sample data structure:
```json
{
  "printers": [
    {
      "human_readable_name": "Zebra QLn420",
      "machine_name": "zebra-qln420",
      "location": "Main Warehouse"
    },
    {
      "human_readable_name": "Dymo Thingy",
      "machine_name": "dymo-thingy",
      "location": "Office"
    }
  ]
}
```
