///|
fn[P : @path.Path] join_to_string(
  base : P,
  relative : @path.RelativePath,
) -> String {
  @path.Path::join(base, relative) |> @path.Path::to_string
}

///|
test "AbsolutePath::AbsolutePath - normalizes an absolute path" {
  let path = @path.AbsolutePath(
    @moon_path.Path("/workspace/./project/src/../README.md"),
  )
  inspect(path.path.to_string(), content="/workspace/project/README.md")
}

///|
test "AbsolutePath::from_string - normalizes an absolute path" {
  let path = @path.AbsolutePath::from_string("/workspace/./project")
  inspect(path.path.to_string(), content="/workspace/project")
}

///|
test "panic_AbsolutePath::AbsolutePath - rejects a relative path" {
  try! (@path.AbsolutePath(@moon_path.Path("workspace/project")) |> ignore)
}

///|
test "AbsolutePath Path::join - joins a normalized relative path" {
  let base = @path.AbsolutePath(@moon_path.Path("/workspace/project"))
  let relative = @path.RelativePath(@moon_path.Path("src/../README.md"))
  inspect(
    join_to_string(base, relative),
    content="/workspace/project/README.md",
  )
}

///|
test "AbsolutePath JSON - round trips through a string" {
  let original = @path.AbsolutePath(@moon_path.Path("/workspace/./project"))
  let decoded : @path.AbsolutePath = @json.from_json(original.to_json())
  inspect(decoded == original, content="true")
  inspect(original.to_json().stringify(), content="\"/workspace/project\"")
}

///|
test "panic_AbsolutePath FromJson - rejects a relative path" {
  try! ((
    @json.from_json(@json.parse("\"workspace/project\"")) : @path.AbsolutePath)
  |> ignore)
}

///|
test "RelativePath::RelativePath - normalizes a relative path" {
  let path = @path.RelativePath(@moon_path.Path("src/./domain/../path.mbt"))
  inspect(path.path.to_string(), content="src/path.mbt")
}

///|
test "RelativePath::from_string - supports chained joins" {
  let path = @path.RelativePath::from_string("./")
    |> @path.RelativePath::join(@path.RelativePath::from_string("s"))
    |> @path.RelativePath::join(@path.RelativePath::from_string("d"))
  inspect(path.path.to_string(), content="s/d")
}

///|
test "panic_RelativePath::RelativePath - rejects an absolute path" {
  try! (@path.RelativePath(@moon_path.Path("/workspace/project")) |> ignore)
}

///|
test "RelativePath Path::join - preserves a relative path" {
  let base = @path.RelativePath(@moon_path.Path("src/domain"))
  let relative = @path.RelativePath(@moon_path.Path("../path.mbt"))
  inspect(join_to_string(base, relative), content="src/path.mbt")
}

///|
test "RelativePath JSON - round trips through a string" {
  let original = @path.RelativePath(@moon_path.Path("src/./path.mbt"))
  let decoded : @path.RelativePath = @json.from_json(original.to_json())
  inspect(decoded == original, content="true")
  inspect(original.to_json().stringify(), content="\"src/path.mbt\"")
}

///|
test "panic_RelativePath FromJson - rejects an absolute path" {
  try! ((
    @json.from_json(@json.parse("\"/workspace/project\"")) : @path.RelativePath)
  |> ignore)
}
