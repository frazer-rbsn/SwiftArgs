# SwiftArgs

A minimal, pure Swift library for making command line tools / interfaces.

[![Travis build status](https://travis-ci.org/frazer-rbsn/SwiftArgs.svg?branch=master)](https://travis-ci.org/frazer-rbsn/SwiftArgs)
[![codebeat](https://codebeat.co/badges/50ae3c45-d0f4-4a10-be51-0b33831d6ad0)](https://codebeat.co/projects/github-com-frazer-rbsn-swiftargs)
[![codecov](https://codecov.io/gh/frazer-rbsn/SwiftArgs/branch/master/graph/badge.svg)](https://codecov.io/gh/frazer-rbsn/SwiftArgs)
![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-Compatible-brightgreen.svg)
![Swift version](https://img.shields.io/badge/Swift-3-orange.svg)
![Swift version](https://img.shields.io/badge/Swift-4-orange.svg)

SwiftArgs uses a very basic and limited parser for parsing commands, but it should suffice for basic usage requirements.
You can use SwiftArgs when making a command-line app in Swift and let it do the parsing work for you.

SwiftArgs is largely model-based -- you define models for the command-line arguments that your program expects. These models are used for validation at runtime. When parsed successfully, instantiated objects of your models are returned to your Command Parser Delegate.
The values of your command model properties will be set when returned to your Command Parser Delegate.

Contributions welcome.

---

### Installation

Requires Swift 3.x or 4.x

Using Swift Package Manager:

```swift
dependencies: [
    .Package(url: "https://github.com/frazer-rbsn/SwiftArgs", majorVersion: 1),
]
```


### Use

If you only need to define commands by keywords, i.e. without required arguments, option switches
or usage documentation, you can use SwiftArgs as follows:

```swift
let parser = CommandParser()

try! parser.register("run", "new", "old")

struct ParserDelegate : CommandParserDelegate {

    func receivedCommand(command: Command) {
        print("received command: \(command)")
    }

    func commandNotSupplied() {
        print("no command supplied")
    }
}

try! parser.parseCommandLine(delegate: ParserDelegate())
```

Otherwise, you can define Command models that conform to the `Command` protocol, as follows:

```swift
struct RunCommand : Command {
    let name = "run"
}
```

You can decorate your command with more functionality by conforming to other protocols.

For example:

```swift
struct RunCommand : Command, HasHelpText {
    let name = "run"
    let helpText "Helpful usage information goes here."
}
```

##### Commands with arguments

You can specify a command to have required ordered arguments, in the form of `command x y z`,
where `x`, `y` and `y` are arguments and will be parsed as `Argument` models.

```swift
struct MoveCommand : CommandWithArguments {
    let name = "move"
    let arguments : [Argument] = [BasicArgument("x"), BasicArgument("y")]
}
```

---

### Build
 * Install Swift 3.x or Swift 4.x toolchain.
 * Run `swift build` in the root of the repo. Unit tests can be run with `swift test`.


### Limitations

* Hasn't been tested on Linux.
* Doesn't support short-form option switches yet, e.g. `mycommand -o`
