# totto2727/x

Focused MoonBit utility packages for logical copying, validated filesystem paths, JSON flattening, and JSON conversions for YAML and TOML values.

This document is canonical `README.mbt.md`; maintain `README.md` as the relative symlink `README.md -> README.mbt.md`.

## Usage

Add the module, then import only the package that owns the needed behavior.

```bash
moon add totto2727/x
```

Use [`copy`](./src/copy/README.mbt.md) for explicit logical-copy semantics, [`path`](./src/path/README.mbt.md) for normalized path values, [`json`](./src/json/README.mbt.md) for flattening and reconstruction, [`yaml`](./src/yaml/README.mbt.md) for YAML JSON conversion, and [`toml`](./src/toml/README.mbt.md) for TOML JSON conversion.

## Key features

- `copy` defines independent logical-copy behavior for built-in and downstream value types.
- `path` separates normalized absolute and relative filesystem paths.
- `json` flattens and reconstructs `Json` values with JSON Pointer or JavaScript paths.
- `yaml` and `toml` provide owned wrappers for standard JSON conversion traits.

## Prerequisites

- **MoonBit**: Use a current stable toolchain compatible with version `0.6.1` of this module.

## Setup

1. Add the module to your MoonBit project.

```bash
moon add totto2727/x
```

2. Import one published subpackage, for example `totto2727/x/json`.

```moonbit
import "totto2727/x/json"
```

## API

Mooncakes provides the canonical API reference for the published module and each package: [`copy`](https://mooncakes.io/docs/totto2727/x/copy), [`path`](https://mooncakes.io/docs/totto2727/x/path), [`json`](https://mooncakes.io/docs/totto2727/x/json), [`yaml`](https://mooncakes.io/docs/totto2727/x/yaml), and [`toml`](https://mooncakes.io/docs/totto2727/x/toml).

## Development

For repository structure and development commands, see [AGENTS.md](./AGENTS.md).

## License

[MIT](./LICENSE)

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
