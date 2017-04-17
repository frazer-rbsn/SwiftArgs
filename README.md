# SwiftArgs

A minimal, pure Swift library for making commandline tools / interfaces.

[![Travis build status](https://travis-ci.org/frazer-rbsn/SwiftArgs.svg?branch=master)](https://travis-ci.org/frazer-rbsn/SwiftArgs)
[![codebeat](https://codebeat.co/badges/50ae3c45-d0f4-4a10-be51-0b33831d6ad0)](https://codebeat.co/projects/github-com-frazer-rbsn-swiftargs)
[![codecov](https://codecov.io/gh/frazer-rbsn/SwiftArgs/branch/master/graph/badge.svg)](https://codecov.io/gh/frazer-rbsn/SwiftArgs)
![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-Compatible-brightgreen.svg)
![Swift version](https://img.shields.io/badge/Swift-3.0.2-orange.svg)

### Limitations

* Hasn't been tested on Linux.
* Doesn't support short-form option switches yet, e.g. `mycommand -o`

### Installation

Using Swift Package Manager:

```swift
dependencies: [
    .Package(url: "https://github.com/frazer-rbsn/SwiftArgs", majorVersion: 0),
]
```

### Use

#### Registering commands with the parser

If you only need to define commands by keywords, i.e. without required arguments, option switches 
or usage documentation, you can use SwiftArgs as follows:

```swift
let parser = CommandParser()

try! parser.register("run", "new", "old")
```

Otherwise, you can define Command models that conform to a Command protocol, as follows:

```swift
struct RunCommand : Command {
    let name = "run"
}

let parser = CommandParser()

try! parser.register(RunCommand())
```

#### Command Models

You can decorate your command with more functionality by conforming to other protocols. 

For example, if you want to add usage information to a command, conform to the `HasHelpText` protocol.
If the user runs the command with invalid arguments, the `helpText` will be printed.

```swift
struct RunCommand : Command, HasHelpText {
    let name = "run"
    let helpText = "Helpful usage information goes here."
}
```

You can specify a command to have arguments, in the form of `command x y`, 
where `x` and `y` are required arguments and will be parsed as `Argument` models. 

```swift
struct MoveCommand : CommandWithArguments {
    let name = "move"
    let arguments : [Argument] = [BasicArgument("x"), BasicArgument("y")]
}
```

#### Parsing the command line

In order to act upon runtime commands, create a `CommandParserDelegate` and pass it to the parser.

```swift
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

### Build

Clone the repository, and run `swift build`. Unit tests can be run with `swift test`.


Contributions welcome.
