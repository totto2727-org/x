///|
/// The string representation used for flattened JSON paths.
pub(all) enum PathFormat {
  /// RFC 6901 JSON Pointer, such as `/users/0/name`.
  JsonPointer
  /// JavaScript-style property and index access, such as `users[0].name`.
  JavaScript
} derive(Eq, Debug)

///|
/// A failure while decoding or reconstructing flattened JSON paths.
pub(all) suberror FlattenJsonError {
  ObjectValue(String)
  EmptyObject(String)
  AmbiguousPointerToken(String)
  InvalidPath(String)
  PathConflict(String)
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
/// Objects and non-empty arrays are traversed recursively. Primitive values and
/// empty arrays remain `Json` leaves. A nested empty object cannot be represented
/// without using an object-valued leaf, so it is rejected. JSON Pointer also
/// rejects object keys matching RFC 6901 array-index syntax because they cannot
/// be distinguished from array indices during reconstruction; JavaScript paths
/// preserve them as bracket-quoted keys.
pub fn flatten(
  json : Json,
  format : PathFormat,
) -> Map[String, Json] raise FlattenJsonError {
  let flattened : Map[String, Json] = Map([])
  flatten_value_(json, [], format, flattened)
  flattened
}

///|
fn flatten_value_(
  value : Json,
  path : Array[PathSegment],
  format : PathFormat,
  flattened : Map[String, Json],
) -> Unit raise FlattenJsonError {
  match value {
    Json::Object(object) if object.is_empty() && !path.is_empty() =>
      raise EmptyObject(checked_path_(path, format))
    Json::Object(object) =>
      for key, child in object {
        let child_path = [..path, Key(key)]
        let path_string = checked_path_(child_path, format)
        if format == JsonPointer && is_pointer_index_token_(key) {
          raise AmbiguousPointerToken(path_string)
        }
        flatten_value_(child, child_path, format, flattened)
      }
    Json::Array(values) if !values.is_empty() =>
      for index, child in values {
        let child_path = [..path, Index(index)]
        ignore(checked_path_(child_path, format))
        flatten_value_(child, child_path, format, flattened)
      }
    _ => flattened[checked_path_(path, format)] = value
  }
}

///|
/// Reconstructs JSON from path-keyed leaf values.
///
/// `format` must match the format passed to `flatten`. Object values are
/// rejected because objects must be represented by their flattened children.
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
      Json::Object(_) => raise ObjectValue(path)
      _ => ()
    }
    let segments = parse_path_(path, format)
    root = Some(insert_value_(root, segments, 0, path, value))
  }
  build_json_(root.unwrap(), "")
}

///|
fn insert_value_(
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
      children[key] = insert_value_(
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
      children[array_index] = insert_value_(
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
fn build_json_(node : BuildNode, path : String) -> Json raise FlattenJsonError {
  match node {
    Value(value) => value
    Object(children) => {
      let object : Map[String, Json] = Map([])
      for key, child in children {
        object[key] = build_json_(child, child_path_(path, key))
      }
      Json::object(object)
    }
    Array(children) => {
      let values : Array[Json] = []
      for index = 0; index < children.length(); index = index + 1 {
        guard children.get(index) is Some(child) else {
          raise ArrayIndexGap(path)
        }
        values.push(build_json_(child, "\{path}[\{index}]"))
      }
      Json::array(values)
    }
  }
}

///|
fn child_path_(path : String, key : String) -> String {
  if path == "" {
    key
  } else {
    "\{path}.\{key}"
  }
}
