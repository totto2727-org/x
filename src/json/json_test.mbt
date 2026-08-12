///|
test "JSON Pointer - flattens and reconstructs containers" {
  let source : Json = {
    "users": [{ "name": "Ada" }, { "name": "Grace" }],
    "a/b": { "~key": true },
    "empty_array": [],
  }
  let flattened = @json.flatten(source, JsonPointer)
  json_inspect(Json::object(flattened), content={
    "/users/0/name": "Ada",
    "/users/1/name": "Grace",
    "/a~1b/~0key": true,
    "/empty_array": [],
  })
  assert_eq(@json.from_flatten_json(flattened, JsonPointer), source)
}

///|
test "JavaScript paths - flatten and reconstruct containers" {
  let source : Json = {
    "users": [{ "name": "Ada" }, { "name": "Grace" }],
    "settings": { "network.access": true },
    "numeric key": { "0": "zero" },
    "empty key": { "": null },
  }
  let flattened = @json.flatten(source, JavaScript)
  json_inspect(Json::object(flattened), content={
    "users[0].name": "Ada",
    "users[1].name": "Grace",
    "settings[\"network.access\"]": true,
    "[\"numeric key\"][\"0\"]": "zero",
    "[\"empty key\"][\"\"]": null,
  })
  assert_eq(@json.from_flatten_json(flattened, JavaScript), source)
}

///|
test "flatten - preserves primitive roots" {
  let pointer = @json.flatten("value", JsonPointer)
  let javascript = @json.flatten("value", JavaScript)
  assert_eq(pointer, { "": "value" })
  assert_eq(javascript, { "": "value" })
  assert_eq(@json.from_flatten_json(pointer, JsonPointer), "value")
  assert_eq(@json.from_flatten_json(javascript, JavaScript), "value")
}

///|
test "from_flatten_json - rejects object values" {
  try
    @json.from_flatten_json({ "/settings": { "enabled": true } }, JsonPointer)
  catch {
    @json.ObjectValue(path) => inspect(path, content="/settings")
    _ => fail("unexpected flatten JSON error")
  } noraise {
    _ => fail("expected object value rejection")
  }
}

///|
test "from_flatten_json - rejects conflicting paths" {
  try
    @json.from_flatten_json(
      { "settings": true, "settings.network": true },
      JavaScript,
    )
  catch {
    @json.PathConflict(path) => inspect(path, content="settings.network")
    _ => fail("unexpected flatten JSON error")
  } noraise {
    _ => fail("expected path conflict")
  }
}

///|
test "from_flatten_json - rejects array index gaps" {
  try @json.from_flatten_json({ "users[1]": "Grace" }, JavaScript) catch {
    @json.ArrayIndexGap(path) => inspect(path, content="users")
    _ => fail("unexpected flatten JSON error")
  } noraise {
    _ => fail("expected array index gap")
  }
}

///|
test "flatten - round-trips an empty root object" {
  let flattened = @json.flatten(Json::empty_object(), JsonPointer)
  assert_true(flattened.is_empty())
  assert_eq(
    @json.from_flatten_json(flattened, JsonPointer),
    Json::empty_object(),
  )
}

///|
test "flatten - rejects nested empty objects" {
  try
    @json.flatten(Json::object({ "empty": Json::empty_object() }), JsonPointer)
  catch {
    @json.EmptyObject(path) => inspect(path, content="/empty")
    _ => fail("unexpected flatten JSON error")
  } noraise {
    _ => fail("expected empty object rejection")
  }
}

///|
test "JSON Pointer - rejects ambiguous numeric object keys" {
  try
    @json.flatten({ "999999999999999999999999": "large" }, JsonPointer)
  catch {
    @json.AmbiguousPointerToken(path) =>
      inspect(path, content="/999999999999999999999999")
    _ => fail("unexpected flatten JSON error")
  } noraise {
    _ => fail("expected ambiguous pointer token rejection")
  }
}

///|
test "JSON Pointer - rejects array indices outside Int range" {
  try
    @json.from_flatten_json(
      { "/users/999999999999999999999999": "large" },
      JsonPointer,
    )
  catch {
    @json.InvalidPath(path) =>
      inspect(path, content="/users/999999999999999999999999")
    _ => fail("unexpected flatten JSON error")
  } noraise {
    _ => fail("expected invalid path rejection")
  }
}

///|
test "JavaScript paths - rejects a bracket segment after dot" {
  for path in ["users.[0]", "users.[\"name\"]"] {
    let flattened : Map[String, Json] = Map([])
    flattened[path] = "value"
    try @json.from_flatten_json(flattened, JavaScript) catch {
      @json.InvalidPath(invalid_path) => assert_eq(invalid_path, path)
      _ => fail("unexpected flatten JSON error")
    } noraise {
      _ => fail("expected invalid path rejection")
    }
  }
}

///|
test "JavaScript paths - rejects non-canonical array indices" {
  for path in ["users[+0]", "users[0x0]", "users[0_0]", "users[01]"] {
    let flattened : Map[String, Json] = Map([])
    flattened[path] = "value"
    try @json.from_flatten_json(flattened, JavaScript) catch {
      @json.InvalidPath(invalid_path) => assert_eq(invalid_path, path)
      _ => fail("unexpected flatten JSON error")
    } noraise {
      _ => fail("expected invalid path rejection")
    }
  }
}

///|
test "from_flatten_json - rejects excessive path depth" {
  let segments : Array[String] = []
  for index = 0; index < 257; index = index + 1 {
    segments.push("k\{index}")
  }
  let path = segments.join(".")
  let flattened : Map[String, Json] = Map([])
  flattened[path] = "value"
  try @json.from_flatten_json(flattened, JavaScript) catch {
    @json.PathDepthExceeded(depth) => assert_eq(depth, 257)
    _ => fail("unexpected flatten JSON error")
  } noraise {
    _ => fail("expected invalid path rejection")
  }
}

///|
test "from_flatten_json - rejects excessive path length" {
  let path = "k".repeat(16385)
  let flattened : Map[String, Json] = Map([])
  flattened[path] = "value"
  try @json.from_flatten_json(flattened, JavaScript) catch {
    @json.PathLengthExceeded(length) => assert_eq(length, 16385)
    _ => fail("unexpected flatten JSON error")
  } noraise {
    _ => fail("expected invalid path rejection")
  }
}

///|
test "flatten - applies the same path bounds as reconstruction" {
  let long_key = "k".repeat(16385)
  let source : Map[String, Json] = Map([])
  source[long_key] = "value"
  try @json.flatten(Json::object(source), JavaScript) catch {
    @json.PathLengthExceeded(length) => assert_eq(length, 16385)
    _ => fail("unexpected flatten JSON error")
  } noraise {
    _ => fail("expected invalid path rejection")
  }
}
