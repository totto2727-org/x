# totto2727/x/json

Flattens `Json` values into path-keyed leaves and reconstructs them with bounded, typed validation.

## Usage

```mbt check
///|
test {
  let source : Json = { "users": [{ "name": "Ada" }] }
  let flattened = flatten(source, JsonPointer)
  assert_eq(flattened, { "/users/0/name": "Ada" })
  assert_eq(from_flatten_json(flattened, JsonPointer), source)
}
```

## Key features

- Supports RFC 6901 JSON Pointer and JavaScript-style paths.
- Expands arrays by default or preserves them as `Json` leaves.
- Rejects conflicting paths, invalid paths, sparse arrays, and oversized paths with `FlattenJsonError`.

## Prerequisites

- **MoonBit**: Use a current stable toolchain compatible with version `0.6.1` of this module.

## Setup

1. Add the module to your MoonBit project.

```bash
moon add totto2727/x
```

2. Import `totto2727/x/json` and select the matching `PathFormat` for both flattening and reconstruction.

## API

[Mooncakes API reference](https://mooncakes.io/docs/totto2727/x/json)

## Development

For repository structure and development commands, see [AGENTS.md](../../AGENTS.md). For the complete module overview, see [the root README](../../README.mbt.md).

## License

[MIT](../../LICENSE)

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
