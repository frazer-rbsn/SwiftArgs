
@testable import SwiftArgs


class MockCommand : Command {
    var name = "mockcommand"
    var helptext = "Mock help text"
    var arguments: [Argument] = []
    
    init(name : String = "mockcommand", helptext : String = "Mock help text", arguments: [Argument] = []) {
        self.name = name
        self.helptext = helptext
        self.arguments = arguments
    }
}

class MockCommandWithOptions : MockCommand, CommandWithOptions {
    var options : [Option] = []
    
    init(name : String = "mockcommand", helptext : String = "Mock help text",
         options : [Option] = [], arguments : [Argument] = []) {
        super.init()
        self.name = name
        self.helptext = helptext
        self.options = options
        self.arguments = arguments
    }
}

class MockCommandWithSubCommand : MockCommand, CommandWithSubCommands {
    var subCommands: [Command] = []
    var usedSubCommand: Command?
    
    init(name : String = "mockcommand", helptext : String = "Mock help text",
         arguments : [Argument] = [], subCommands : [Command] = []) {
        super.init()
        self.name = name
        self.helptext = helptext
        self.arguments = arguments
        self.subCommands = subCommands
    }
}

class MockOption : Option {
    var name = "mockoption"
    var shortName = "o"
    var set = false
    
    init(name : String = "mockoption", shortName : String = "o", set : Bool = false) {
        self.name = name
        self.shortName = shortName
        self.set = set
    }
}

class MockOptionWithArgument : OptionWithArgument {
    var name = "mockoptionwitharg"
    var shortName = "a"
    var argumentName = "arg"
    var set = false
    var value : String? = nil
    
    init(name : String = "mockoptionwitharg", shortName : String = "a",
         argumentName : String = "", set : Bool = false, value : String? = nil) {
        self.name = name
        self.shortName = shortName
        self.argumentName = argumentName
        self.set = set
        self.value = value
    }
}

class MockArgument : Argument {
    var name = "mockarg"
    var value : String? = nil
    
    init(name : String = "mockarg", value : String? = nil) {
        self.name = name
        self.value = value
    }
}

class MockCommandParserDelegate : CommandParserDelegate {
    var commandNotSuppliedFlag : Bool = false
    var receivedCommand : Bool = false
    var command : Command?
    
    func commandNotSupplied() {
        commandNotSuppliedFlag = true
    }
    
    func receivedCommand(command: Command) {
        self.command = command
        receivedCommand = true
    }
}
