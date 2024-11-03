import startest.{describe, it}
import startest/expect
import yodel

pub fn yaml_tests() {
  describe("yaml", [
    it("should load basic yaml file", fn() {
      let assert Ok(config) = yodel.load("./test/fixtures/short.yaml")
      config
      |> yodel.get_string_or("foo.bar", "error")
      |> expect.to_equal("fooey")
    }),
    it("should not load fake yaml file", fn() {
      yodel.load("fake.yaml")
      |> expect.to_be_error
      Nil
    }),
    it("should load full yaml value", fn() {
      let assert Ok(config) =
        yodel.load(
          "foo:
              bar: fooey",
        )
      config
      |> yodel.get_string_or("foo.bar", "error")
      |> expect.to_equal("fooey")
    }),
  ])
}
