import envoy
import gleam/dict.{type Dict}
import gleam/option.{type Option, None, Some}
import startest.{describe, it}
import startest/expect
import yodel
import yodel/resolver
import yodel/types.{ResolverError, UnresolvedPlaceholder}

pub fn resolver_tests() {
  describe("resolver", [
    it("resolves simple placeholder default", fn() {
      dict.from_list([#("foo", "${BAR:fooey}")])
      |> resolver.resolve_properties(yodel.default_options())
      |> expect.to_be_ok
      |> dict.get("foo")
      |> expect.to_be_ok
      |> expect.to_equal("fooey")
    }),
    it("resolves simple placeholder", fn() {
      dict.from_list([#("BAR", Some("fooey"))])
      |> with_env(fn() {
        dict.from_list([#("foo", "${BAR}")])
        |> resolver.resolve_properties(yodel.default_options())
        |> expect.to_be_ok
        |> dict.get("foo")
        |> expect.to_be_ok
        |> expect.to_equal("fooey")
      })
    }),
    it("resolves nested placeholders", fn() {
      dict.from_list([#("BAZ", Some("fooey"))])
      |> with_env(fn() {
        dict.from_list([#("foo", "${BAR:${BAZ}}")])
        |> resolver.resolve_properties(yodel.default_options())
        |> expect.to_be_ok
        |> dict.get("foo")
        |> expect.to_be_ok
        |> expect.to_equal("fooey")
      })
    }),
    it("resolves nested placeholder defaults", fn() {
      dict.from_list([#("foo", "${BAR:${BAZ:fooey}}")])
      |> resolver.resolve_properties(yodel.default_options())
      |> expect.to_be_ok
      |> dict.get("foo")
      |> expect.to_be_ok
      |> expect.to_equal("fooey")
    }),
    it("resolves multiple placeholders", fn() {
      dict.from_list([#("BAR", Some("fooey")), #("BAZ", Some("dooey"))])
      |> with_env(fn() {
        dict.from_list([#("foo", "${BAR}-${BAZ}")])
        |> resolver.resolve_properties(yodel.default_options())
        |> expect.to_be_ok
        |> dict.get("foo")
        |> expect.to_be_ok
        |> expect.to_equal("fooey-dooey")
      })
    }),
    it("resolved multiple placeholder defaults", fn() {
      dict.from_list([#("foo", "${BAR:fooey}-${BAZ:dooey}")])
      |> resolver.resolve_properties(yodel.default_options())
      |> expect.to_be_ok
      |> dict.get("foo")
      |> expect.to_be_ok
      |> expect.to_equal("fooey-dooey")
    }),
    it("fails in strict mode with missing env var", fn() {
      let options =
        yodel.default_options() |> yodel.with_resolve_mode(yodel.strict)
      dict.from_list([#("foo", "${MISSING}")])
      |> resolver.resolve_properties(options)
      |> expect.to_be_error
      |> expect.to_equal(
        ResolverError(UnresolvedPlaceholder("MISSING", "${MISSING}")),
      )
    }),
    it("preserves placeholder in lenient mode", fn() {
      let options =
        yodel.default_options() |> yodel.with_resolve_mode(yodel.lenient)
      dict.from_list([#("foo", "${MISSING}")])
      |> resolver.resolve_properties(options)
      |> expect.to_be_ok
      |> dict.get("foo")
      |> expect.to_be_ok
      |> expect.to_equal("${MISSING}")
    }),
    it("ignores default value when placeholder resolves", fn() {
      dict.from_list([#("BAR", Some("fooey"))])
      |> with_env(fn() {
        dict.from_list([#("foo", "${BAR:fooed}")])
        |> resolver.resolve_properties(yodel.default_options())
        |> expect.to_be_ok
        |> dict.get("foo")
        |> expect.to_be_ok
        |> expect.to_equal("fooey")
      })
    }),
  ])
}

fn with_env(envs: Dict(String, Option(String)), handler: fn() -> Nil) {
  let old_envs = preserve_envs(envs)
  set_envs(envs)
  handler()
  restore_envs(old_envs)
}

fn preserve_envs(
  envs: Dict(String, Option(String)),
) -> Dict(String, Option(String)) {
  dict.map_values(envs, fn(key, _) {
    case envoy.get(key) {
      Ok(value) -> Some(value)
      _ -> None
    }
  })
}

fn set_envs(envs: Dict(String, Option(String))) {
  dict.each(envs, fn(key, value) {
    case value {
      Some(value) -> envoy.set(key, value)
      None -> envoy.unset(key)
    }
  })
}

fn restore_envs(old_envs: Dict(String, Option(String))) {
  dict.each(old_envs, fn(key, old_value) {
    case old_value {
      Some(old_value) -> envoy.set(key, old_value)
      None -> envoy.unset(key)
    }
  })
}
