# totto2727/x/yaml

Wraps upstream YAML values so they can use MoonBit's standard JSON conversion traits without violating foreign-trait rules. See the [module README](../../README.mbt.md#setup) for consumer setup and package imports.

## YAML conversion

```mbt check
///|
test "convert a structured JSON value to YAML and back" {
  let configuration : Yaml = @json.from_json(
    @json.parse(
      (
        #|{
        #|  "name": "example",
        #|  "enabled": true,
        #|  "items": ["a", null]
        #|}
      ),
    ),
  )
  @json.json_inspect(configuration.to_json(), content={
    "name": "example",
    "enabled": true,
    "items": ["a", null],
  })
}
```

## Package behavior

- Converts nested YAML maps and arrays to JSON.
- Preserves integer representations when decoding JSON numbers where possible.
- Rejects non-finite numbers because JSON cannot represent them.

## API

[Mooncakes API reference](https://mooncakes.io/docs/totto2727/x/yaml)

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
