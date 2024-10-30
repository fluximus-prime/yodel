import startest.{describe, it}
import startest/expect
import yodel

pub fn main() {
  startest.run(startest.default_config())
}

pub fn yodel_tests() {
  describe("yodel", [
    describe("yaml tests", [
      it("should load basic yaml value", fn() {
        let assert Ok(config) = yodel.load_string("foo.bar: fooey\n")
        config
        |> yodel.get_string_or("foo.bar", "error")
        |> expect.to_equal("fooey")
      }),
      it("should load full yaml value", fn() {
        let assert Ok(config) =
          yodel.load_string(
            "foo:
              bar: fooey",
          )
        config
        |> yodel.get_string_or("foo.bar", "error")
        |> expect.to_equal("fooey")
      }),
      it("should load basic yaml file", fn() {
        let assert Ok(config) = yodel.load_file("./test/fixtures/short.yaml")
        config
        |> yodel.get_string_or("foo.bar", "error")
        |> expect.to_equal("fooey")
      }),
    ]),
    describe("json tests", [
      it("should load basic json value", fn() {
        let assert Ok(config) = yodel.load_string("\"foo.bar\": \"fooey\"\n")
        config
        |> yodel.get_string_or("foo.bar", "error")
        |> expect.to_equal("fooey")
      }),
      it("should load full json value", fn() {
        let assert Ok(config) =
          yodel.load_string(
            "{
              \"foo\": {
                \"bar\": \"fooey\"
              }
            }",
          )
        config
        |> yodel.get_string_or("foo.bar", "error")
        |> expect.to_equal("fooey")
      }),
      it("should load basic json file", fn() {
        let assert Ok(config) = yodel.load_file("./test/fixtures/short.json")
        config
        |> yodel.get_string_or("foo.bar", "error")
        |> expect.to_equal("fooey")
      }),
    ]),
  ])
}
