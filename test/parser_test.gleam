// import gleam/list
// import startest.{describe, it}
// import startest/expect
// import test_helpers.{with_env}
// import yodel.{type Format}
// import yodel/parsers/toml
// import yodel/parsers/yaml
// import yodel/types.{File}

// type TestCase {
//   TestCase(
//     format_name: String,
//     format: Format,
//     extensions: List(String),
//     content: String,
//   )
// }

// pub fn parser_tests() {
//   let test_cases = [
//     TestCase(
//       format_name: "json",
//       format: yodel.json,
//       extensions: ["json", "jsn", "json5", "jsonc"],
//       content: "",
//     ),
//     TestCase(
//       format_name: "yaml",
//       format: yodel.yaml,
//       extensions: ["yaml", "yml"],
//       content: "",
//     ),
//     TestCase(
//       format_name: "toml",
//       format: yodel.toml,
//       extensions: ["toml", "tml"],
//       content: "",
//     ),
//   ]

//   describe(
//     "parser",
//     list.map(test_cases, fn(test_case) {
//       let TestCase(format_name, format, extension, _content) = test_case

//       describe("format detection", [
//         describe("by file extension", [
//           it(
//             "detects " <> format_name <> " from ." <> extension <> " extension",
//             fn() {
//               toml.detect(File("foo." <> extension)) |> expect.to_equal(format)
//             },
//           ),
//         ]),
//         describe("by content", [
//           it("detects " <> format_name <> " from content", fn() {
//             toml.detect(File("foo." <> extension)) |> expect.to_equal(format)
//           }),
//         ]),
//       ])
//     }),
//   )
// }
// //     describe(format_name, [
// //       it("loads simple file", fn() {
// //         yodel.default_options()
// //         |> yodel.with_format(format)
// //         |> yodel.load_with_options("./test/fixtures/simple." <> extension)
// //         |> expect.to_be_ok
// //         Nil
// //       }),
// //       it("loads complex file", fn() {
// //         yodel.default_options()
// //         |> yodel.with_format(format)
// //         |> yodel.load_with_options("./test/fixtures/complex." <> extension)
// //         |> expect.to_be_ok
// //         Nil
// //       }),
// //       it("does not load fake file", fn() {
// //         yodel.default_options()
// //         |> yodel.with_format(format)
// //         |> yodel.load_with_options("fake." <> extension)
// //         |> expect.to_be_error
// //         Nil
// //       }),
// //       it("loads file with no extension", fn() {
// //         yodel.default_options()
// //         |> yodel.with_format(format)
// //         |> yodel.load_with_options("./test/fixtures/no-ext-" <> extension)
// //         |> expect.to_be_ok
// //         Nil
// //       }),
// //       it("loads basic value", fn() {
// //         yodel.default_options()
// //         |> yodel.with_format(format)
// //         |> yodel.load_with_options(basic_input)
// //         |> expect.to_be_ok
// //         |> yodel.get_string("foo.bar")
// //         |> expect.to_be_ok
// //         |> expect.to_equal("fooey")
// //       }),
// //       it("loads array", fn() {
// //         yodel.default_options()
// //         |> yodel.with_format(format)
// //         |> yodel.load_with_options(array_input)
// //         |> expect.to_be_ok
// //         |> yodel.get_string("foo[1].baz")
// //         |> expect.to_be_ok
// //         |> expect.to_equal("fooed")
// //       }),
// //       it("returns a string", fn() {
// //         yodel.default_options()
// //         |> yodel.with_format(format)
// //         |> yodel.load_with_options(string_input)
// //         |> expect.to_be_ok
// //         |> yodel.get_string("foo.bar")
// //         |> expect.to_be_ok
// //         |> expect.to_equal("fooey")
// //       }),
// //       it("returns an int", fn() {
// //         yodel.default_options()
// //         |> yodel.with_format(format)
// //         |> yodel.load_with_options(int_input)
// //         |> expect.to_be_ok
// //         |> yodel.get_int("foo.bar")
// //         |> expect.to_be_ok
// //         |> expect.to_equal(42)
// //       }),
// //       it("returns a float", fn() {
// //         yodel.default_options()
// //         |> yodel.with_format(format)
// //         |> yodel.load_with_options(float_input)
// //         |> expect.to_be_ok
// //         |> yodel.get_float("foo.bar")
// //         |> expect.to_be_ok
// //         |> float.to_precision(3)
// //         |> expect.to_equal(99.999)
// //       }),
// //       it("returns a bool", fn() {
// //         yodel.default_options()
// //         |> yodel.with_format(format)
// //         |> yodel.load_with_options(bool_input)
// //         |> expect.to_be_ok
// //         |> yodel.get_bool("foo.bar")
// //         |> expect.to_be_ok
// //         |> expect.to_equal(True)
// //       }),
// //     ])
// //   }),
// // )
// // }
