# SwiftArgs

**This library is no longer maintained. Please use [Swift Argument Parser](https://github.com/apple/swift-argument-parser) instead.**
---
A minimal, pure Swift library for making command-line tools / interfaces.

[![Travis build status](https://travis-ci.org/frazer-rbsn/SwiftArgs.svg?branch=master)](https://travis-ci.org/frazer-rbsn/SwiftArgs)
[![codebeat](https://codebeat.co/badges/50ae3c45-d0f4-4a10-be51-0b33831d6ad0)](https://codebeat.co/projects/github-com-frazer-rbsn-swiftargs)
![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-Compatible-brightgreen.svg)
![Swift version](https://img.shields.io/badge/Swift-5-orange.svg)

SwiftArgs uses a very basic and limited parser for parsing commands, but it should suffice for basic usage requirements.
You can use SwiftArgs when making a command-line interface in Swift and let it do the parsing work for you.

Contributions welcome.

---

### Install

Using Swift Package Manager:

```swift
dependencies: [
  .Package(url: "https://github.com/frazer-rbsn/SwiftArgs", majorVersion: 1.1),
]
```

---

### Limitations

* Hasn't been tested on Linux.
* Currently no support for subcommands
* Doesn't support short-form option switches yet, e.g. `mycommand -o`
