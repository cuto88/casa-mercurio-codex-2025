# MIRAI Modbus helpers

## Generate bitwise binary_sensors

The generator emits template `binary_sensor` entries for every bit of the raw
registers 4000 (status word) and 4001 (status code).

```
python tools/mirai_generate_bit_sensors.py \
  --log-path /config/www/mirai/mirai_modbus_log.csv \
  --output packages/mirai/mirai_bit_sensors.generated.yaml
```

- The log file is only checked for existence; the generated sensors always read
  from `sensor.mirai_status_word_raw` and `sensor.mirai_status_code_raw`.
- The output file is a package-friendly YAML that can be included directly by
  Home Assistant.
