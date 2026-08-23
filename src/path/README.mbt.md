# totto2727/x/path

Provides normalized absolute and relative filesystem path value types that preserve their form through parsing, joining, and JSON conversion.

## Usage

```mbt check
///|
test {
  let base = AbsolutePath::from_string("/workspace/project")
  let child = RelativePath::from_string("src/../README.md")
  assert_eq(Path::join(base, child).to_string(), "/workspace/project/README.md")
}
```

## Key features

- Separates normalized absolute and relative path forms at construction.
- Permits joins only with validated `RelativePath` values.
- Encodes values as normalized JSON strings and rejects mismatched forms on decoding.

## Prerequisites

- **MoonBit**: Use a current stable toolchain compatible with version `0.6.1` of this module.

## Setup

1. Add the module to your MoonBit project.

```bash
moon add totto2727/x
```

2. Import `totto2727/x/path` and construct the absolute or relative type required by your boundary.

## API

[Mooncakes API reference](https://mooncakes.io/docs/totto2727/x/path)

## Development

For repository structure and development commands, see [AGENTS.md](../../AGENTS.md). For the complete module overview, see [the root README](../../README.mbt.md).

## License

[MIT](../../LICENSE)

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
