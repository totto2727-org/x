# totto2727/x/any_collection

Store values of different types in a mutable or persistent map and read them through typed key references.
See the [module README](../../README.mbt.md#setup) for setup and package imports.

## Usage

Update a retry count in a mutable map and create a persistent snapshot without changing its baseline.

```mbt check
///|
test "update a retry context without changing its baseline snapshot" {
  let request_id : @any_collection.AnyRef[String, String] = @any_collection.AnyRef::AnyRef(
    "request_id",
  )
  let retry_count : @any_collection.AnyRef[String, Int32] = @any_collection.AnyRef::AnyRef(
    "retry_count",
  )
  let live_context = @any_collection.AnyMutableMap::AnyMutableMap([])
  live_context.set(request_id, "req-42")
  live_context.set(retry_count, 0)
  live_context.set(retry_count, live_context.get_or(retry_count, 0) + 1)

  let baseline = @any_collection.AnyImmutableHashMap::AnyImmutableHashMap([
    request_id.entry("req-42"),
    retry_count.entry(0),
  ])
  let retry_snapshot = baseline.added(
    retry_count,
    live_context.get_or(retry_count, 0),
  )

  inspect(live_context.get_or(request_id, ""), content="req-42")
  inspect(live_context.get_or(retry_count, 0), content="1")
  inspect(baseline.get_or(retry_count, 0), content="0")
  inspect(retry_snapshot.get_or(retry_count, 0), content="1")
}
```

## Migrate from `totto2727/any-collection`

Replace the standalone module requirement with `"totto2727/x@0.9.0"` and change the package import to `"totto2727/x/any_collection" @any_collection`.
Keep the alias to reuse existing call sites.
Update both sides of public APIs that exchange map or reference types, because the old and new package types are distinct.
Keep a direct `Yoorkin/any` dependency if your code imports it, for example to implement `@any.Anyable` for a custom value type.

## API

[Mooncakes API reference](https://mooncakes.io/docs/totto2727/x/any_collection)
