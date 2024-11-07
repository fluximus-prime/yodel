import startest.{describe, it}
import startest/expect
import yodel

pub fn toml_tests() {
  describe("toml", [
    it("should load simple file", fn() {
      yodel.load("./test/fixtures/simple.toml")
      |> expect.to_be_ok
      Nil
    }),
    it("should load complex file", fn() {
      yodel.load("./test/fixtures/complex.toml")
      |> expect.to_be_ok
      Nil
    }),
    it("should not load fake file", fn() {
      yodel.load("fake.toml")
      |> expect.to_be_error
      Nil
    }),
    it("should load simple string", fn() {
      yodel.load("foo.bar = \"fooey\"")
      |> expect.to_be_ok
      Nil
    }),
    it("should parse basic value", fn() {
      "
      [foo]
      bar = \"fooey\"
      "
      |> yodel.load
      |> expect.to_be_ok
      |> yodel.get_string_or("foo.bar", "error")
      |> expect.to_equal("fooey")
    }),
    it("should parse array", fn() {
      "
      [[foo]]
      bar = \"fooey\"

      [[foo]]
      baz = \"fooed\"
      "
      |> yodel.load
      |> expect.to_be_ok
      |> yodel.get_string_or("foo[1].baz", "error")
      |> expect.to_equal("fooed")
    }),
  ])
}
