import startest.{describe, it}
import startest/expect
import yodel

pub fn toml_tests() {
  describe("toml", [
    it("should load basic toml file", fn() {
      let assert Ok(config) = yodel.load("./test/fixtures/short.toml")
      config
      |> yodel.get_string_or("foo.bar", "error")
      |> expect.to_equal("fooey")
    }),
    it("should not load fake toml file", fn() {
      yodel.load("fake.toml")
      |> expect.to_be_error
      Nil
    }),
    it("should load full toml value", fn() {
      let assert Ok(config) =
        yodel.load(
          "[foo]
          bar = \"fooey\"",
        )
      config
      |> yodel.get_string_or("foo.bar", "error")
      |> expect.to_equal("fooey")
    }),
  ])
}
