# totto2727/x

Focused MoonBit utility packages for bounded and heterogeneous collections, logical copying, validated filesystem paths, JSON flattening, and JSON conversions for YAML and TOML values.

## Usage

Choose the checked workflow that matches the utility task:

- [`any_collection`](./src/any_collection/README.mbt.md#usage) reads values of different types from the same map through typed references.
- [`copy`](./src/copy/README.mbt.md#usage) creates an independent mutable copy while leaving the original value unchanged.
- [`ring_buffer`](./src/ring_buffer/README.mbt.md#usage) retains the newest values in a fixed-capacity FIFO collection.
- [`path`](./src/path/README.mbt.md#usage) resolves and normalizes an absolute and relative filesystem path.
- [`json`](./src/json/README.mbt.md#usage) flattens a nested document and reconstructs the original structure.
- [`yaml`](./src/yaml/README.mbt.md#usage) preserves nested configuration values through YAML-backed JSON conversion.
- [`toml`](./src/toml/README.mbt.md#usage) parses a structured TOML configuration into nested JSON.

## Key features

- `any_collection` provides mutable and persistent maps with the same typed reference API.
- `copy` defines independent logical-copy behavior for built-in and downstream value types.
- `ring_buffer` provides bounded FIFO storage with logical-order traversal.
- `path` separates normalized absolute and relative filesystem paths.
- `json` flattens and reconstructs `Json` values with JSON Pointer or JavaScript paths.
- `yaml` and `toml` provide owned wrappers for standard JSON conversion traits.

## Prerequisites

- **MoonBit**: Use `moon 0.1.20261117` or a compatible stable toolchain.

## Setup

1. Add the module to your MoonBit project.

```bash
moon add totto2727/x
```

2. Add only the selected package entry inside the consumer package's `import { ... }` declaration in `moon.pkg`.

| Package | `moon.pkg` entry |
| --- | --- |
| `any_collection` | `"totto2727/x/any_collection" @any_collection` |
| `copy` | `"totto2727/x/copy" @x_copy` |
| `ring_buffer` | `"totto2727/x/ring_buffer" @x_ring_buffer` |
| `path` | `"totto2727/x/path" @x_path` |
| `json` | `"totto2727/x/json" @x_json` |
| `yaml` | `"totto2727/x/yaml" @x_yaml` |
| `toml` | `"totto2727/x/toml" @x_toml` |

## API

Mooncakes provides the canonical API reference for the published module and each package: [`any_collection`](https://mooncakes.io/docs/totto2727/x/any_collection), [`copy`](https://mooncakes.io/docs/totto2727/x/copy), [`ring_buffer`](https://mooncakes.io/docs/totto2727/x/ring_buffer), [`path`](https://mooncakes.io/docs/totto2727/x/path), [`json`](https://mooncakes.io/docs/totto2727/x/json), [`yaml`](https://mooncakes.io/docs/totto2727/x/yaml), and [`toml`](https://mooncakes.io/docs/totto2727/x/toml).

## Development

For repository structure and development commands, see [AGENTS.md](./AGENTS.md).

## License

[MIT](./LICENSE)

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
