import gleam/dict.{type Dict}

pub type YodelContext {
  YodelContext(props: Properties)
}

pub type YodelError {
  InvalidPath(error: String)
  InvalidContent(error: String)
  UnknownConfigType(error: String)
}

pub type Properties =
  Dict(String, String)
