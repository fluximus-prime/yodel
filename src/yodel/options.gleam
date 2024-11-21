pub opaque type YodelOptions {
  YodelOptions(format: Format, resolve: ResolveOptions, validate: Bool)
}

pub type Format {
  Auto
  Json
  Toml
  Yaml
}

pub type ResolveOptions {
  ResolveOptions(enabled: Bool, mode: ResolveMode)
}

pub type ResolveMode {
  Strict
  Lenient
}

pub fn new(
  format format: Format,
  resolve_enabled resolve_enabled: Bool,
  resolve_mode resolve_mode: ResolveMode,
  validate validate: Bool,
) -> YodelOptions {
  YodelOptions(
    format:,
    resolve: new_resolve_options(enabled: resolve_enabled, mode: resolve_mode),
    validate:,
  )
}

pub fn new_resolve_options(
  enabled enabled: Bool,
  mode mode: ResolveMode,
) -> ResolveOptions {
  ResolveOptions(enabled:, mode:)
}

pub fn default() -> YodelOptions {
  new(Auto, True, Lenient, True)
}

pub fn with_format(
  options options: YodelOptions,
  format format: Format,
) -> YodelOptions {
  new(format, options.resolve.enabled, options.resolve.mode, options.validate)
}

pub fn with_resolve_enabled(
  options options: YodelOptions,
  enabled enabled: Bool,
) -> YodelOptions {
  new(options.format, enabled, options.resolve.mode, options.validate)
}

pub fn with_resolve_mode(
  options options: YodelOptions,
  mode mode: ResolveMode,
) -> YodelOptions {
  new(options.format, options.resolve.enabled, mode, options.validate)
}

pub fn with_validate(
  options options: YodelOptions,
  validate validate: Bool,
) -> YodelOptions {
  new(options.format, options.resolve.enabled, options.resolve.mode, validate)
}

pub fn format(options options: YodelOptions) -> Format {
  options.format
}

pub fn resolve_enabled(options options: YodelOptions) -> Bool {
  options.resolve.enabled
}

pub fn resolve_mode(options options: YodelOptions) -> ResolveMode {
  options.resolve.mode
}

pub fn validate_enabled(options options: YodelOptions) -> Bool {
  options.validate
}
