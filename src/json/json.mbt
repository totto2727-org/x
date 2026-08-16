///|
/// The string representation used for flattened JSON paths.
pub(all) enum PathFormat {
  /// RFC 6901 JSON Pointer, such as `/users/0/name`.
  JsonPointer
  /// JavaScript-style property and index access, such as `users[0].name`.
  JavaScript
} derive(Eq, Debug)

///|
/// Controls whether arrays are expanded into indexed paths.
pub(all) enum ArrayMode {
  /// Expands array elements into indexed paths.
  Expand
  /// Preserves each array as a single `Json` leaf.
  Preserve
} derive(Eq, Debug)

///|
/// A failure while decoding or reconstructing flattened JSON paths.
pub(all) suberror FlattenJsonError {
  /// A flattened leaf contains a non-empty object that must be expanded instead.
  ObjectValue(String)
  /// A JSON Pointer key is indistinguishable from an array index.
  AmbiguousPointerToken(String)
  /// A path does not conform to the selected path format.
  InvalidPath(String)
  /// A path exceeds 16,384 UTF-16 code units.
  PathLengthExceeded(Int)
  /// A path exceeds 256 segments.
  PathDepthExceeded(Int)
  /// Multiple flattened paths require incompatible values at the same location.
  PathConflict(String)
  /// Reconstructed array indices contain a gap.
  ArrayIndexGap(String)
} derive(Eq, Debug)

///|
priv enum BuildNode {
  Value(Json)
  Object(Map[String, BuildNode])
  Array(Map[Int, BuildNode])
}

///|
/// Flattens JSON containers into path-keyed JSON leaf values.
///
/// The caller must select RFC 6901 JSON Pointer or JavaScript-style paths.
/// Objects are traversed recursively. Arrays are expanded by default; pass
/// `array_mode=Preserve` to retain each array as a single `Json` leaf. Primitive
/// values and empty arrays remain `Json` leaves. A root empty object produces an
/// empty map, while nested empty objects remain `Json` leaves. JSON Pointer also
/// rejects object keys matching RFC 6901 array-index syntax because they cannot
/// be distinguished from array indices during reconstruction; JavaScript paths
/// preserve them as bracket-quoted keys.
pub fn flatten(
  json : Json,
  format : PathFormat,
  array_mode? : ArrayMode = Expand,
) -> Map[String, Json] raise FlattenJsonError {
  let flattened : Map[String, Json] = Map([])
  flatten_value(json, [], format, array_mode, flattened)
  flattened
}

///|
fn flatten_value(
  value : Json,
  path : Array[PathSegment],
  format : PathFormat,
  array_mode : ArrayMode,
  flattened : Map[String, Json],
) -> Unit raise FlattenJsonError {
  match value {
    Json::Object(object) if object.is_empty() && !path.is_empty() =>
      flattened[checked_path(path, format)] = value
    Json::Object(object) =>
      for key, child in object {
        let child_path = [..path, Key(key)]
        let path_string = checked_path(child_path, format)
        if format == JsonPointer && is_array_index_token(key) {
          raise AmbiguousPointerToken(path_string)
        }
        flatten_value(child, child_path, format, array_mode, flattened)
      }
    Json::Array(values) if array_mode == Expand && !values.is_empty() =>
      for index, child in values {
        let child_path = [..path, Index(index)]
        ignore(checked_path(child_path, format))
        flatten_value(child, child_path, format, array_mode, flattened)
      }
    _ => flattened[checked_path(path, format)] = value
  }
}

///|
/// Reconstructs JSON from path-keyed leaf values.
///
/// `format` must match the format passed to `flatten`. Non-empty object values
/// are rejected because they must be represented by their flattened children;
/// empty objects are valid leaves.
/// Paths longer than 16,384 UTF-16 code units or deeper than 256 segments are
/// rejected to keep reconstruction within a bounded typed-error boundary.
pub fn from_flatten_json(
  flattened : Map[String, Json],
  format : PathFormat,
) -> Json raise FlattenJsonError {
  if flattened.is_empty() {
    return Json::empty_object()
  }
  let mut root : BuildNode? = None
  for path, value in flattened {
    match value {
      Json::Object(object) if !object.is_empty() => raise ObjectValue(path)
      _ => ()
    }
    let segments = parse_path(path, format)
    root = Some(insert_value(root, segments, 0, path, value))
  }
  build_json(root.unwrap(), "")
}

///|
fn insert_value(
  node : BuildNode?,
  segments : Array[PathSegment],
  index : Int,
  path : String,
  value : Json,
) -> BuildNode raise FlattenJsonError {
  if index == segments.length() {
    guard node is None else { raise PathConflict(path) }
    return Value(value)
  }
  match segments[index] {
    Key(key) => {
      let children = match node {
        None => Map([])
        Some(Object(children)) => children
        Some(_) => raise PathConflict(path)
      }
      children[key] = insert_value(
        children.get(key),
        segments,
        index + 1,
        path,
        value,
      )
      Object(children)
    }
    Index(array_index) => {
      let children = match node {
        None => Map([])
        Some(Array(children)) => children
        Some(_) => raise PathConflict(path)
      }
      children[array_index] = insert_value(
        children.get(array_index),
        segments,
        index + 1,
        path,
        value,
      )
      Array(children)
    }
  }
}

///|
fn build_json(node : BuildNode, path : String) -> Json raise FlattenJsonError {
  match node {
    Value(value) => value
    Object(children) => {
      let object : Map[String, Json] = Map([])
      for key, child in children {
        object[key] = build_json(child, child_path(path, key))
      }
      Json::object(object)
    }
    Array(children) => {
      let values : Array[Json] = []
      for index = 0; index < children.length(); index = index + 1 {
        guard children.get(index) is Some(child) else {
          raise ArrayIndexGap(path)
        }
        values.push(build_json(child, "\{path}[\{index}]"))
      }
      Json::array(values)
    }
  }
}

///|
fn child_path(path : String, key : String) -> String {
  if path == "" {
    key
  } else {
    "\{path}.\{key}"
  }
}
