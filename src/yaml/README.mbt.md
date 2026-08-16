# totto2727/x/yaml

Wraps upstream YAML values so they can use MoonBit's standard JSON conversion traits without violating foreign-trait rules.

## Usage

```mbt check
///|
test {
  let value : Yaml = @json.from_json(@json.parse("42"))
  assert_eq(value.to_json().stringify(), "42")
}
```

## Key features

- Converts nested YAML maps and arrays to JSON.
- Preserves integer representations when decoding JSON numbers where possible.
- Rejects non-finite numbers because JSON cannot represent them.

## Prerequisites

- **MoonBit**: Use a current stable toolchain compatible with version `0.6.0` of this module.

## Setup

1. Add the module to your MoonBit project.

```bash
moon add totto2727/x
```

2. Import `totto2727/x/yaml` and wrap upstream values with `Yaml::Yaml` before JSON conversion.

## API

[Mooncakes API reference](https://mooncakes.io/docs/totto2727/x/yaml)

## Development

For repository structure and development commands, see [AGENTS.md](../../AGENTS.md). For the complete module overview, see [the root README](../../README.mbt.md).

## License

[MIT](../../LICENSE)

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
