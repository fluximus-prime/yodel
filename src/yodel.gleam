import gleam/result
import yodel/context.{type Context}
import yodel/errors.{type ConfigError, type GetError}
import yodel/options.{type Options, Lenient, Strict}
import yodel/parser
import yodel/properties.{type Properties}
import yodel/resolver
import yodel/validator

pub type ResolveMode =
  options.ResolveMode

pub const strict = options.Strict

pub const lenient = options.Lenient

pub type Format =
  options.Format

pub const auto_detect = options.Auto

pub const json = options.Json

pub const toml = options.Toml

pub const yaml = options.Yaml

pub fn load(from input: String) -> Result(Context, ConfigError) {
  load_with_options(default_options(), input)
}

pub fn load_with_options(
  with options: Options,
  from input: String,
) -> Result(Context, ConfigError) {
  use parsed <- parse(input, options)
  use validated <- validate(parsed, options)
  use resolved <- resolve(validated, options)
  Ok(context.new(resolved))
}

pub fn get_string(ctx: Context, key: String) -> Result(String, GetError) {
  context.get_string(ctx, key)
}

pub fn get_string_or(ctx: Context, key: String, default: String) -> String {
  context.get_string_or(ctx, key, default)
}

pub fn get_int(ctx: Context, key: String) -> Result(Int, GetError) {
  context.get_int(ctx, key)
}

pub fn get_int_or(ctx: Context, key: String, default: Int) -> Int {
  context.get_int_or(ctx, key, default)
}

pub fn get_float(ctx: Context, key: String) -> Result(Float, GetError) {
  context.get_float(ctx, key)
}

pub fn get_float_or(ctx: Context, key: String, default: Float) -> Float {
  context.get_float_or(ctx, key, default)
}

pub fn get_bool(ctx: Context, key: String) -> Result(Bool, GetError) {
  context.get_bool(ctx, key)
}

pub fn get_bool_or(ctx: Context, key: String, default: Bool) -> Bool {
  context.get_bool_or(ctx, key, default)
}

pub fn default_options() -> Options {
  options.default()
}

pub fn with_format(options options: Options, format format: Format) -> Options {
  options.with_format(options:, format:)
}

pub fn with_resolve_enabled(
  options options: Options,
  enabled enabled: Bool,
) -> Options {
  options.with_resolve_enabled(options:, enabled:)
}

pub fn enable_resolve(options options: Options) -> Options {
  with_resolve_enabled(options, True)
}

pub fn disable_resolve(options options: Options) -> Options {
  with_resolve_enabled(options, False)
}

pub fn with_resolve_mode(
  options options: Options,
  mode mode: ResolveMode,
) -> Options {
  options.with_resolve_mode(options:, mode:)
}

pub fn strict_resolve(options options: Options) -> Options {
  with_resolve_mode(options, Strict)
}

pub fn lenient_resolve(options options: Options) -> Options {
  with_resolve_mode(options, Lenient)
}

pub fn with_validation_enabled(
  options options: Options,
  validate validate: Bool,
) -> Options {
  options.with_validation_enabled(options:, validate:)
}

pub fn enable_validation(options options: Options) -> Options {
  with_validation_enabled(options, True)
}

pub fn disable_validation(options options: Options) -> Options {
  with_validation_enabled(options, False)
}

pub fn get_format(options options: Options) -> Format {
  options.get_format(options)
}

pub fn is_resolve_enabled(options options: Options) -> Bool {
  options.is_resolve_enabled(options)
}

pub fn get_resolve_mode(options options: Options) -> ResolveMode {
  options.get_resolve_mode(options)
}

pub fn is_validation_enabled(options options: Options) -> Bool {
  options.is_validation_enabled(options)
}

fn parse(
  input: String,
  options: Options,
  next: fn(Properties) -> Result(Context, ConfigError),
) -> Result(Context, ConfigError) {
  parser.parse(input, options)
  |> result.then(next)
}

fn validate(
  props: Properties,
  options: Options,
  handler: fn(Properties) -> Result(Context, ConfigError),
) -> Result(Context, ConfigError) {
  case options.is_validation_enabled(options) {
    True -> validator.validate_properties(props)
    False -> props |> Ok
  }
  |> result.then(handler)
}

fn resolve(
  props: Properties,
  options: Options,
  handler: fn(Properties) -> Result(Context, ConfigError),
) -> Result(Context, ConfigError) {
  case options.is_resolve_enabled(options) {
    True -> resolver.resolve_properties(props, options)
    False -> props |> Ok
  }
  |> result.then(handler)
}
