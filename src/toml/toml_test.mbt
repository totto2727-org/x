///|
test "TomlValue ToJson - flattens parsed TOML values" {
  let value = @toml.TomlValue(
    @upstream_toml.parse(
      (
        #|title = "example"
        #|created = 1979-05-27T07:32:00Z
        #|count = 3
        #|ratio = 1.5
        #|enabled = true
        #|items = [1, 2]
        #|
        #|[owner]
        #|name = "Ada"
      ),
    ),
  )
  json_inspect(value.to_json(), content={
    "title": "example",
    "created": "1979-05-27T07:32:00Z",
    "count": 3,
    "ratio": 1.5,
    "enabled": true,
    "items": [1, 2],
    "owner": { "name": "Ada" },
  })
}

///|
test "TomlValue FromJson - converts flat JSON values" {
  let value : @toml.TomlValue = @json.from_json(
    @json.parse(
      (
        #|{
        #|  "title": "example",
        #|  "count": 3,
        #|  "ratio": 1.5,
        #|  "enabled": true,
        #|  "items": [1, 2],
        #|  "owner": { "name": "Ada" }
        #|}
      ),
    ),
  )
  json_inspect(value.to_json(), content={
    "title": "example",
    "count": 3,
    "ratio": 1.5,
    "enabled": true,
    "items": [1, 2],
    "owner": { "name": "Ada" },
  })
}

///|
test "TomlValue FromJson - keeps a date string as TomlString" {
  let value : @toml.TomlValue = @json.from_json(
    @json.parse("\"1979-05-27T07:32:00Z\""),
  )
  debug_inspect(value.value, content="TomlString(\"1979-05-27T07:32:00Z\")")
}

///|
test "panic_TomlValue FromJson - rejects null" {
  try! ((@json.from_json(Json::null()) : @toml.TomlValue) |> ignore)
}

///|
test "panic_TomlValue FromJson - rejects a heterogeneous array" {
  try! ((@json.from_json(@json.parse("[1, \"two\"]")) : @toml.TomlValue)
  |> ignore)
}

///|
test "panic_TomlValue ToJson - rejects NaN" {
  @toml.TomlValue(@upstream_toml.TomlFloat(@double.not_a_number)).to_json()
  |> ignore
}

///|
test "panic_TomlValue ToJson - rejects infinity" {
  @toml.TomlValue(@upstream_toml.TomlFloat(@double.infinity)).to_json()
  |> ignore
}
