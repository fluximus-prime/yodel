import startest.{describe, it}
import startest/expect
import yodel

pub fn main() {
  startest.run(startest.default_config())
}

pub fn yodel_tests() {
  describe("base", [
    it("should parse string", fn() {
      "foo.bar: abc123"
      |> yodel.load
      |> expect.to_be_ok
      |> yodel.get_string("foo.bar")
      |> expect.to_be_ok
      |> expect.to_equal("abc123")
    }),
    it("should parse int", fn() {
      "foo.bar: 42"
      |> yodel.load
      |> expect.to_be_ok
      |> yodel.get_int("foo.bar")
      |> expect.to_be_ok
      |> expect.to_equal(42)
    }),
    it("should parse float", fn() {
      "foo.bar: 42.24"
      |> yodel.load
      |> expect.to_be_ok
      |> yodel.get_float("foo.bar")
      |> expect.to_be_ok
      |> expect.to_equal(42.24)
    }),
    it("should parse bool", fn() {
      "foo.bar: true"
      |> yodel.load
      |> expect.to_be_ok
      |> yodel.get_bool("foo.bar")
      |> expect.to_be_ok
      |> expect.to_equal(True)
    }),
  ])
}
