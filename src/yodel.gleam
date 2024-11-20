import gleam/result
import yodel/context
import yodel/options.{type YodelOptions} as cfg
import yodel/parser
import yodel/resolver
import yodel/types.{
  type ConfigError, type GetError, type Properties, type YodelContext,
}
import yodel/validate

pub type ResolveMode =
  cfg.ResolveMode

pub const strict = cfg.Strict

pub const lenient = cfg.Lenient

pub type Format =
  cfg.Format

pub const auto_detect = cfg.Auto

pub const json = cfg.Json

pub const toml = cfg.Toml

pub const yaml = cfg.Yaml

pub fn load(from input: String) -> Result(YodelContext, ConfigError) {
  load_with_options(default_options(), input)
}

pub fn load_with_options(
  with options: YodelOptions,
  from input: String,
) -> Result(YodelContext, ConfigError) {
  use props <- do_parse(input, options)
  use valid <- do_validate(props, options)
  use resolved <- do_resolve(valid, options)
  Ok(context.new(resolved))
}

pub fn get_string(ctx: YodelContext, key: String) -> Result(String, GetError) {
  context.get_string(ctx, key)
}

pub fn get_string_or(ctx: YodelContext, key: String, default: String) -> String {
  context.get_string_or(ctx, key, default)
}

pub fn get_int(ctx: YodelContext, key: String) -> Result(Int, GetError) {
  context.get_int(ctx, key)
}

pub fn get_int_or(ctx: YodelContext, key: String, default: Int) -> Int {
  context.get_int_or(ctx, key, default)
}

pub fn get_float(ctx: YodelContext, key: String) -> Result(Float, GetError) {
  context.get_float(ctx, key)
}

pub fn get_float_or(ctx: YodelContext, key: String, default: Float) -> Float {
  context.get_float_or(ctx, key, default)
}

pub fn get_bool(ctx: YodelContext, key: String) -> Result(Bool, GetError) {
  context.get_bool(ctx, key)
}

pub fn get_bool_or(ctx: YodelContext, key: String, default: Bool) -> Bool {
  context.get_bool_or(ctx, key, default)
}

pub fn options(
  format: Format,
  resolve_enabled: Bool,
  resolve_mode: ResolveMode,
  validate: Bool,
) -> YodelOptions {
  cfg.new(
    format:,
    resolve_enabled: resolve_enabled,
    resolve_mode: resolve_mode,
    validate:,
  )
}

pub fn default_options() -> YodelOptions {
  cfg.default()
}

pub fn with_format(
  options options: YodelOptions,
  format format: Format,
) -> YodelOptions {
  cfg.with_format(options:, format:)
}

pub fn with_resolve_enabled(
  options options: YodelOptions,
  enabled enabled: Bool,
) -> YodelOptions {
  cfg.with_resolve_enabled(options:, enabled:)
}

pub fn with_resolve_mode(
  options options: YodelOptions,
  mode mode: ResolveMode,
) -> YodelOptions {
  cfg.with_resolve_mode(options:, mode:)
}

pub fn with_validation(
  options options: YodelOptions,
  validate validate: Bool,
) -> YodelOptions {
  cfg.with_validate(options:, validate:)
}

pub fn format(options options: YodelOptions) -> Format {
  cfg.format(options)
}

pub fn resolve_enabled(options options: YodelOptions) -> Bool {
  cfg.resolve_enabled(options)
}

pub fn resolve_mode(options options: YodelOptions) -> ResolveMode {
  cfg.resolve_mode(options)
}

pub fn validate(options options: YodelOptions) -> Bool {
  cfg.validate(options)
}

fn do_parse(
  input: String,
  options: YodelOptions,
  next: fn(Properties) -> Result(YodelContext, ConfigError),
) -> Result(YodelContext, ConfigError) {
  parser.parse(input, options)
  |> result.then(next)
}

fn do_validate(
  props: Properties,
  options: YodelOptions,
  handler: fn(Properties) -> Result(YodelContext, ConfigError),
) -> Result(YodelContext, ConfigError) {
  case cfg.validate(options) {
    True -> validate.properties(props)
    False -> props |> Ok
  }
  |> result.then(handler)
}

fn do_resolve(
  props: Properties,
  options: YodelOptions,
  handler: fn(Properties) -> Result(YodelContext, ConfigError),
) -> Result(YodelContext, ConfigError) {
  case cfg.resolve_enabled(options) {
    True -> resolver.resolve_properties(props, options)
    False -> props |> Ok
  }
  |> result.then(handler)
}
