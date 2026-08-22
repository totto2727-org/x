# totto2727/x/json

Flattens `Json` values into path-keyed leaves and reconstructs them with bounded, typed validation. See the [module README](../../README.mbt.md#setup) for consumer setup and package imports.

## Reconstruction

```mbt check
///|
test {
  let flattened : Map[String, Json] = { "/users/0/name": "Ada" }
  assert_eq(from_flatten_json(flattened, JsonPointer), {
    "users": [{ "name": "Ada" }],
  })
}
```

## Package behavior

- Supports RFC 6901 JSON Pointer and JavaScript-style paths.
- Expands arrays by default or preserves them as `Json` leaves.
- Rejects conflicting paths, invalid paths, sparse arrays, and oversized paths with `FlattenJsonError`.

## API

[Mooncakes API reference](https://mooncakes.io/docs/totto2727/x/json)

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
