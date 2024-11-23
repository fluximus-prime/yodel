import gleam/dict.{type Dict}
import gleam/result
import yodel/errors.{type GetError, PathNotFound}

pub opaque type Properties {
  Properties(entries: Dict(Path, Value))
}

pub type Path =
  String

pub type Value =
  String

pub fn new() -> Properties {
  Properties(entries: dict.new())
}

pub fn get(from: Properties, get: Path) -> Result(Value, GetError) {
  dict.get(from.entries, get)
  |> result.map_error(fn(_) { PathNotFound(get) })
}

pub fn insert(
  into props: Properties,
  for path: Path,
  insert value: Value,
) -> Properties {
  Properties(entries: dict.insert(props.entries, path, value))
}

pub fn merge(
  into old_props: Properties,
  from new_props: Properties,
) -> Properties {
  Properties(dict.merge(old_props.entries, new_props.entries))
}

pub fn fold(
  over props: Properties,
  from initial: a,
  with fun: fn(a, Path, Value) -> a,
) -> a {
  dict.fold(props.entries, initial, fun)
}

pub fn size(props: Properties) -> Int {
  dict.size(props.entries)
}
