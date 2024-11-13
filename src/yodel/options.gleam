pub opaque type YodelOptions {
  YodelOptions(format: Format, resolve: Bool, validate: Bool)
}

pub type Format {
  Auto
  Json
  Toml
  Yaml
}

pub fn new(
  format format: Format,
  resolve resolve: Bool,
  validate validate: Bool,
) -> YodelOptions {
  YodelOptions(format:, resolve:, validate:)
}

pub fn default() -> YodelOptions {
  new(Auto, True, True)
}

pub fn with_format(
  options options: YodelOptions,
  format format: Format,
) -> YodelOptions {
  new(format, options.resolve, options.validate)
}

pub fn with_resolve(
  options options: YodelOptions,
  resolve resolve: Bool,
) -> YodelOptions {
  new(options.format, resolve, options.validate)
}

pub fn with_validate(
  options options: YodelOptions,
  validate validate: Bool,
) -> YodelOptions {
  new(options.format, options.resolve, validate)
}

pub fn format(options options: YodelOptions) -> Format {
  options.format
}

pub fn resolve(options options: YodelOptions) -> Bool {
  options.resolve
}

pub fn validate(options options: YodelOptions) -> Bool {
  options.validate
}
