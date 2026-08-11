///|
/// Describes a normalized filesystem path value.
///
/// `join` accepts a relative path so implementations can preserve their path
/// form without revalidating the result.
pub(open) trait Path {
  fn from_string(String) -> Self raise
  fn to_string(Self) -> String
  fn join(Self, RelativePath) -> Self
}

///|
/// A normalized absolute filesystem path.
pub struct AbsolutePath {
  path : @moon_path.Path
} derive(Debug, Eq)

///|
/// Constructs a normalized absolute path.
pub fn AbsolutePath::AbsolutePath(path : @moon_path.Path) -> AbsolutePath raise {
  let normalized = path.normalize()
  guard normalized.is_absolute() else { fail("absolute path required") }
  { path: normalized }
}

///|
pub impl Path for AbsolutePath with fn from_string(value) {
  AbsolutePath::AbsolutePath(@moon_path.Path(value))
}

///|
pub impl Path for AbsolutePath with fn to_string(self) {
  self.path.to_string()
}

///|
pub impl Path for AbsolutePath with fn join(self, relative) {
  // The underlying join normalizes the result. A RelativePath operand preserves
  // the absolute form, so rerunning the raising constructor is unnecessary.
  AbsolutePath::{ path: self.path.join(relative.path) }
}

///|
pub impl ToJson for AbsolutePath with fn to_json(self) {
  self.path.to_string().to_json()
}

///|
pub impl @json.FromJson for AbsolutePath with fn from_json(json, path) {
  let value : String = @json.from_json(json, path~)
  AbsolutePath::from_string(value) catch {
    _ => raise @json.JsonDecodeError((path, "absolute path required"))
  }
}

///|
/// A normalized relative filesystem path.
pub struct RelativePath {
  path : @moon_path.Path
} derive(Debug, Eq)

///|
/// Constructs a normalized relative path.
pub fn RelativePath::RelativePath(path : @moon_path.Path) -> RelativePath raise {
  let normalized = path.normalize()
  guard !normalized.is_absolute() else { fail("relative path required") }
  { path: normalized }
}

///|
pub impl Path for RelativePath with fn from_string(value) {
  RelativePath::RelativePath(@moon_path.Path(value))
}

///|
pub impl Path for RelativePath with fn to_string(self) {
  self.path.to_string()
}

///|
pub impl Path for RelativePath with fn join(self, relative) {
  // The underlying join normalizes the result. A RelativePath operand preserves
  // the relative form, so rerunning the raising constructor is unnecessary.
  RelativePath::{ path: self.path.join(relative.path) }
}

///|
pub impl ToJson for RelativePath with fn to_json(self) {
  self.path.to_string().to_json()
}

///|
pub impl @json.FromJson for RelativePath with fn from_json(json, path) {
  let value : String = @json.from_json(json, path~)
  RelativePath::from_string(value) catch {
    _ => raise @json.JsonDecodeError((path, "relative path required"))
  }
}
