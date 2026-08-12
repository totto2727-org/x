///|
/// Owns an upstream YAML value so standard JSON traits can be implemented
/// without violating MoonBit's foreign-trait implementation rule.
pub struct Yaml {
  value : @upstream_yaml.Yaml
} derive(Eq, Debug)

///|
/// Wraps an upstream YAML value for standard JSON conversion.
pub fn Yaml::Yaml(value : @upstream_yaml.Yaml) -> Yaml {
  { value, }
}

///|
/// Delegates JSON serialization to the upstream YAML implementation.
pub impl ToJson for Yaml with fn to_json(self) {
  self.value.to_json()
}

///|
/// Converts JSON values into the corresponding flat wrapped YAML value.
///
/// JSON numbers with an integer representation become `Yaml::Integer`; all
/// other JSON numbers become `Yaml::Real`. `Yaml::BadValue` is never produced.
pub impl @json.FromJson for Yaml with fn from_json(json, path) {
  match json {
    Json::Null => Yaml::Yaml(@upstream_yaml.Yaml::Null)
    Json::True => Yaml::Yaml(@upstream_yaml.Yaml::Boolean(true))
    Json::False => Yaml::Yaml(@upstream_yaml.Yaml::Boolean(false))
    Json::String(value) => Yaml::Yaml(@upstream_yaml.Yaml::String(value))
    Json::Number(value, repr~) => {
      let representation = match repr {
        Some(representation) => representation
        None => value.to_string()
      }
      try @string.parse_int64(representation) catch {
        _ => Yaml::Yaml(@upstream_yaml.Yaml::Real(value, repr=representation))
      } noraise {
        integer => Yaml::Yaml(@upstream_yaml.Yaml::Integer(integer))
      }
    }
    Json::Array(_) => {
      let values : Array[Yaml] = @json.from_json(json, path~)
      Yaml::Yaml(@upstream_yaml.Yaml::Array(values.map(value => value.value)))
    }
    Json::Object(_) => {
      let values : Map[String, Yaml] = @json.from_json(json, path~)
      Yaml::Yaml(
        @upstream_yaml.Yaml::Map(values.map((_, value) => value.value)),
      )
    }
  }
}
