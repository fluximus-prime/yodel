import yodel/types.{type Properties}

pub fn parse(doc: a, parser: fn(a) -> Properties) -> Properties {
  parser(doc)
}
