#!/bin/bash

curl -X POST http://localhost:4567/preview/zebra_lager \
-H "Accept: application/json" \
-H "Content-Type: application/json" \
-d '
{
  "barcode": 4012700301024,
  "product_title": "Leo!!", 
  "product_type": "Brautrock", 
  "sku": "asdf-1234",
  "options": ["Farbe: sdf", "Material: bsdf", "Version: 2.5"],
  "size": "36.5"
}' \
-v \
--output label.png
