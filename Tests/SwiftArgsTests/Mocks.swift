@testable import SwiftArgs

class MockCommand : Command {
    var name : String = "mockcommand"
    var helptext: String = "mockcommand help text"
    required init(){}
}

class MockCommandWithOptions : MockCommand, CommandWithOptions {
    var options: [Option] = [MockOption()]
}

class MockCommandWithArguments : MockCommand, CommandWithArguments {
    var arguments: [Argument] = [MockArgument()]
}

class MockCommandWithOptionsAndArguments : MockCommand, CommandWithOptions, CommandWithArguments {
    var options: [Option] = [MockOption()]
    var arguments: [Argument] = [MockArgument()]
}

class MockSubCommand : Command {
    var name : String = "mocksubcommand"
    var helptext: String = "mocksubcommand help text"
    required init(){}
}

class MockCommandWithSubCommands : MockCommand, CommandWithSubCommands {
    var subCommands: [Command] = [MockSubCommand()]
    var usedSubCommand: Command? = nil
}

class MockCommandWithOptionsAndSubCommands : MockCommand, CommandWithOptions, CommandWithSubCommands {
    var options: [Option] = [MockOption()]
    var subCommands: [Command] = [MockSubCommand()]
    var usedSubCommand: Command? = nil
}

class MockCommandWithArgumentsAndSubCommands : MockCommand, CommandWithArguments, CommandWithSubCommands {
    var arguments: [Argument] = [MockArgument()]
    var subCommands: [Command] = [MockSubCommand()]
    var usedSubCommand: Command? = nil
}

class MockCommandWithOptionsAndArgumentsAndSubCommands : MockCommand, CommandWithOptions, CommandWithArguments, CommandWithSubCommands {
    var options: [Option] = [MockOption()]
    var arguments: [Argument] = [MockArgument()]
    var subCommands: [Command] = [MockSubCommand()]
    var usedSubCommand: Command? = nil
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
