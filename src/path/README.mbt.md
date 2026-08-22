# totto2727/x/path

Provides normalized absolute and relative filesystem path value types that preserve their form through parsing, joining, and JSON conversion. See the [module README](../../README.mbt.md#setup) for consumer setup and package imports.

## Normalized joins

```mbt check
///|
test {
  let base = AbsolutePath::from_string("/workspace/project")
  let child = RelativePath::from_string("src/../README.md")
  assert_eq(Path::join(base, child).to_string(), "/workspace/project/README.md")
}
```

## Package behavior

- Separates normalized absolute and relative path forms at construction.
- Permits joins only with validated `RelativePath` values.
- Encodes values as normalized JSON strings and rejects mismatched forms on decoding.

## API

[Mooncakes API reference](https://mooncakes.io/docs/totto2727/x/path)

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
