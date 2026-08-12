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
