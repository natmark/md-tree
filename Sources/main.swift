import Foundation
import OptionKit

// md-tree -f filename.md 大見出し 中見出し 小見出し
let arguments = Array(CommandLine.arguments.dropFirst())

let fileOption = Option(trigger: OptionTrigger.Mixed("f", "filename"), numberOfParameters: 1, helpDescription: "Markdown file")
let parser = OptionParser(definitions: [fileOption])

do {
    let (options, _) = try parser.parse(parameters: arguments)
    if let filePath = options[fileOption]?.first {
        print(filePath)
        let hierarchy = arguments.dropFirst(2)
        print(hierarchy)
    }
} catch let OptionKitError.InvalidOption(description: description) {
    print(description)
    exit(EXIT_FAILURE)
}
