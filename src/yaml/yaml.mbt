///|
/// Owns an upstream YAML value so standard JSON traits can be implemented
/// without violating MoonBit's foreign-trait implementation rule.
pub struct Yaml {
  /// The wrapped upstream YAML value, exposed as a public readonly field.
  value : @upstream_yaml.Yaml
} derive(Eq, Debug)

///|
/// Wraps an upstream YAML value for standard JSON conversion.
pub fn Yaml::Yaml(value : @upstream_yaml.Yaml) -> Yaml {
  { value, }
}

///|
/// Converts wrapped YAML into flat JSON.
///
/// YAML `inf` and `nan` reals abort conversion because JSON cannot represent
/// non-finite numbers. `Yaml::BadValue` also has no JSON representation.
pub impl ToJson for Yaml with fn to_json(self) {
  match self.value {
    @upstream_yaml.Null => Json::null()
    @upstream_yaml.Map(values) =>
      Json::object(values.map((_, value) => Yaml::Yaml(value).to_json()))
    @upstream_yaml.Array(values) =>
      Json::array(values.map(value => Yaml::Yaml(value).to_json()))
    @upstream_yaml.Boolean(value) => Json::boolean(value)
    @upstream_yaml.String(value) => Json::string(value)
    @upstream_yaml.Integer(value) =>
      Json::number(value.to_double(), repr=value.to_string())
    @upstream_yaml.Real(value, repr~) => {
      if value.is_nan() ||
        value == @double.infinity ||
        value == @double.neg_infinity {
        abort("non-finite YAML reals cannot be represented as JSON")
      }
      Json::number(value, repr~)
    }
    @upstream_yaml.BadValue =>
      abort("Yaml::BadValue cannot be represented as JSON")
  }
}

///|
pub extend Yaml with ToJson::{to_json}

///|
/// Converts JSON values into the corresponding flat wrapped YAML value.
///
/// JSON numbers with an integer representation become `Yaml::Integer`; all
/// other finite JSON numbers become `Yaml::Real`. Non-finite numbers are
/// rejected, and `Yaml::BadValue` is never produced.
pub impl @json.FromJson for Yaml with fn from_json(json, path) {
  match json {
    Json::Null => Yaml::Yaml(@upstream_yaml.Yaml::Null)
    Json::True => Yaml::Yaml(@upstream_yaml.Yaml::Boolean(true))
    Json::False => Yaml::Yaml(@upstream_yaml.Yaml::Boolean(false))
    Json::String(value) => Yaml::Yaml(@upstream_yaml.Yaml::String(value))
    Json::Number(value, repr~) => {
      // `Json::number(@double.not_a_number)` can construct `Number(NaN)`, so
      // the `Json::Number` variant alone does not guarantee a finite value.
      if value.is_nan() ||
        value == @double.infinity ||
        value == @double.neg_infinity {
        raise @json.JsonDecodeError((path, "YAML numbers must be finite"))
      }
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
