@testable import SwiftArgs

class MockCommand : Command {
    static var name : String = "mockcommand"
    var helpText: String = "mockcommand help text"
    required init() {}
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
    static var name : String = "mocksubcommand"
    var helpText: String = "mocksubcommand help text"
    required init(){}
}

class MockCommandWithSubCommands : MockCommand, CommandWithSubCommands {
    var subcommands: [Command] = [MockSubCommand()]
    var usedSubcommand: Command? = nil
}

class MockCommandWithOptionsAndSubCommands : MockCommand, CommandWithOptions, CommandWithSubCommands {
    var options: [Option] = [MockOption()]
    var subcommands: [Command] = [MockSubCommand()]
    var usedSubcommand: Command? = nil
}

class MockCommandWithArgumentsAndSubCommands : MockCommand, CommandWithArguments, CommandWithSubCommands {
    var arguments: [Argument] = [MockArgument()]
    var subcommands: [Command] = [MockSubCommand()]
    var usedSubcommand: Command? = nil
}

class MockCommandWithOptionsAndArgumentsAndSubCommands : MockCommand, CommandWithOptions, CommandWithArguments, CommandWithSubCommands {
    var options: [Option] = [MockOption()]
    var arguments: [Argument] = [MockArgument()]
    var subcommands: [Command] = [MockSubCommand()]
    var usedSubcommand: Command? = nil
}

class MockOption : Option {
    var name = "mockoption"
    var shortName = "o"
    var set = false
    
    required init() {}
    
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
    
    required init() {}
    
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
    
    required init() {}
    
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
