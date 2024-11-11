pub opaque type YodelOptions {
  YodelOptions(format: Format, resolve: Bool)
}

pub type Format {
  Auto
  Json
  Toml
  Yaml
}

pub fn new(format format: Format, resolve resolve: Bool) -> YodelOptions {
  YodelOptions(format: format, resolve: resolve)
}

pub fn default() -> YodelOptions {
  new(Auto, True)
}

pub fn with_format(
  options options: YodelOptions,
  format format: Format,
) -> YodelOptions {
  new(format, options.resolve)
}

pub fn with_resolve(
  options options: YodelOptions,
  resolve resolve: Bool,
) -> YodelOptions {
  new(options.format, resolve)
}

pub fn format(options options: YodelOptions) -> Format {
  options.format
}

pub fn resolve(options options: YodelOptions) -> Bool {
  options.resolve
}
