# totto2727/x/toml

Wraps upstream TOML values so they can use MoonBit's standard JSON conversion traits without violating foreign-trait rules.

## Usage

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

## Key features

- Converts nested TOML tables and arrays to JSON.
- Decodes JSON strings as `TomlString` and does not infer date-time variants.
- Rejects JSON `null` and non-finite numbers because TOML or JSON has no matching value.

## Prerequisites

- **MoonBit**: Use a current stable toolchain compatible with version `0.6.0` of this module.

## Setup

1. Add the module to your MoonBit project.

```bash
moon add totto2727/x
```

2. Import `totto2727/x/toml` and wrap upstream values with `TomlValue::TomlValue` before JSON conversion.

## API

[Mooncakes API reference](https://mooncakes.io/docs/totto2727/x/toml)

## Development

For repository structure and development commands, see [AGENTS.md](../../AGENTS.md). For the complete module overview, see [the root README](../../README.mbt.md).

## License

[MIT](../../LICENSE)

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
