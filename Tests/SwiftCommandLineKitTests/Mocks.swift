
@testable import SwiftCommandLineKit

class MockCommand : Command {
    var name = "mockcommand"
    var helptext = "Mock help text"
    var options : [Option] = []
    var arguments : [Argument] = []
    var subCommands: [Command] = []
    var usedSubCommand: Command?
    
    init(name : String = "mockcommand", helptext : String = "Mock help text",
         subCommands : [Command] = [], args : [Argument] = [], options : [Option] = []) {
        self.name = name
        self.helptext = helptext
        self.subCommands = subCommands
        self.arguments = args
        self.options = options
    }
    
    func run() {}
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

