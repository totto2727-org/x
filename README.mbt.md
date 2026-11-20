# totto2727/x

Focused MoonBit utility packages for heterogeneous collections, logical copying, validated filesystem paths, and JSON flattening.

## Usage

Choose the checked workflow that matches the utility task:

- [`any_collection`](./src/any_collection/README.mbt.md#usage) reads values of different types from the same map through typed references.
- [`copy`](./src/copy/README.mbt.md#usage) creates an independent mutable copy while leaving the original value unchanged.
- [`path`](./src/path/README.mbt.md#usage) resolves and normalizes an absolute and relative filesystem path.
- [`json`](./src/json/README.mbt.md#usage) flattens a nested document and reconstructs the original structure.

## Key features

- `any_collection` provides mutable and persistent maps with the same typed reference API.
- `copy` defines independent logical-copy behavior for built-in and downstream value types.
- `path` separates normalized absolute and relative filesystem paths.
- `json` flattens and reconstructs `Json` values with JSON Pointer or JavaScript paths.

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
| `path` | `"totto2727/x/path" @x_path` |
| `json` | `"totto2727/x/json" @x_json` |

## API

Mooncakes provides the canonical API reference for [`any_collection`](https://mooncakes.io/docs/totto2727/x/any_collection), [`copy`](https://mooncakes.io/docs/totto2727/x/copy), [`path`](https://mooncakes.io/docs/totto2727/x/path), and [`json`](https://mooncakes.io/docs/totto2727/x/json).

## Migrate from 0.9

Version 0.10 removes `totto2727/x/ring_buffer`, `totto2727/x/yaml`, and `totto2727/x/toml`. Use these MoonBitStack packages directly:

| Removed package | Replacement | Migration |
| --- | --- | --- |
| `ring_buffer` | [`moonbitstack/moonstl/seq`](https://mooncakes.io/docs/moonbitstack/moonstl/seq) | Use `RingBuffer::new(capacity=...)`. Replace `push`, `pop`, and `peek` with `push_back`, `pop_front`, and `front`. `push_back` returns the oldest value when it overwrites it. |
| `yaml` | [`moonbitstack/moonyaml`](https://mooncakes.io/docs/moonbitstack/moonyaml) | Use `loads` for YAML text to `Json` and `dumps` for `Json` to YAML text. |
| `toml` | [`moonbitstack/moontoml`](https://mooncakes.io/docs/moonbitstack/moontoml) | Use `loads` for TOML text to `Json` and `dumps` for `Json` to TOML text. Use `decode` and `encode` to preserve TOML value types, including dates and times. |

The replacement ring buffer grows its storage on demand up to the configured element limit. The replacement parsers can produce non-finite JSON numbers, unlike the removed wrappers. TOML `dumps` also writes JSON `null` as an empty string and can interpret date-like strings as TOML dates or times. Validate these cases before conversion if your application relied on the old behavior.

## Development

For repository structure and development commands, see [AGENTS.md](./AGENTS.md).

## License

[MIT](./LICENSE)

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
