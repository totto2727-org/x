# totto2727/x/toml

Wraps upstream TOML values so they can use MoonBit's standard JSON conversion traits without violating foreign-trait rules. See the [module README](../../README.mbt.md#setup) for consumer setup and package imports.

## TOML conversion

```mbt check
///|
test "convert a parsed TOML configuration to JSON" {
  let configuration = TomlValue::TomlValue(
    @upstream_toml.parse(
      (
        #|title = "example"
        #|enabled = true
        #|
        #|[owner]
        #|name = "Ada"
      ),
    ),
  )
  @json.json_inspect(configuration.to_json(), content={
    "title": "example",
    "enabled": true,
    "owner": { "name": "Ada" },
  })
}
```

## Package behavior

- Converts nested TOML tables and arrays to JSON.
- Decodes JSON strings as `TomlString` and does not infer date-time variants.
- Rejects JSON `null` and non-finite numbers because TOML or JSON has no matching value.

## API

[Mooncakes API reference](https://mooncakes.io/docs/totto2727/x/toml)

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
