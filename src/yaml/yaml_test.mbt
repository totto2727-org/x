///|
test "Yaml FromJson - decodes an integer number" {
  let value : @yaml.Yaml = @json.from_json(@json.parse("42"))
  debug_inspect(value.value, content="Integer(42)")
}

///|
test "Yaml FromJson - decodes a real number" {
  let value : @yaml.Yaml = @json.from_json(@json.parse("1.5"))
  debug_inspect(value.value, content="Real(1.5, repr=\"1.5\")")
}

///|
test "Yaml JSON - round trips flat values" {
  let value : @yaml.Yaml = @json.from_json(
    @json.parse(
      (
        #|{
        #|  "name": "example",
        #|  "enabled": true,
        #|  "count": 3,
        #|  "ratio": 1.5,
        #|  "items": ["a", null]
        #|}
      ),
    ),
  )
  json_inspect(value.to_json(), content={
    "name": "example",
    "enabled": true,
    "count": 3,
    "ratio": 1.5,
    "items": ["a", null],
  })
}

///|
test "panic_Yaml FromJson - rejects NaN" {
  try! ((@json.from_json(Json::number(@double.not_a_number)) : @yaml.Yaml)
  |> ignore)
}

///|
test "panic_Yaml FromJson - rejects positive numeric overflow" {
  try! ((@json.from_json(@json.parse("1e999999999")) : @yaml.Yaml) |> ignore)
}

///|
test "panic_Yaml FromJson - rejects negative numeric overflow" {
  try! ((@json.from_json(@json.parse("-1e999999999")) : @yaml.Yaml) |> ignore)
}

///|
test "panic_Yaml ToJson - rejects NaN" {
  @yaml.Yaml(@upstream_yaml.Yaml::Real(@double.not_a_number, repr=".nan")).to_json()
  |> ignore
}

///|
test "panic_Yaml ToJson - rejects infinity" {
  @yaml.Yaml(@upstream_yaml.Yaml::Real(@double.infinity, repr=".inf")).to_json()
  |> ignore
}

///|
test "panic_Yaml ToJson - rejects nested negative infinity" {
  @yaml.Yaml(
    @upstream_yaml.Yaml::Array([
      @upstream_yaml.Yaml::Real(@double.neg_infinity, repr="-.inf"),
    ]),
  ).to_json()
  |> ignore
}
