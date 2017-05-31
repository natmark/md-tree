import Foundation
import OptionKit

enum ConsoleOption {
    case file
    case tab
    case emptyline

    var option: Option {
        switch self {
        case .file:
            return Option(trigger: .Mixed(flag.0,flag.1), numberOfParameters: 1, helpDescription: "Markdown file")
        case .tab:
            return Option(trigger:.Mixed(flag.0,flag.1))
        case .emptyline:
            return Option(trigger:.Mixed(flag.0,flag.1))
        }
    }
    var flag: (Character, String) {
        switch self {
        case .file:
            return ("f", "filename")
        case .tab:
            return ("t", "tab")
        case .emptyline:
            return ("e", "emptyline")
        }
    }
}
enum LineType {
    case headLine(Int)
    case content
    case none

    var level: Int {
        switch self {
        case .headLine(let headLevel):
            return headLevel
        case .content:
            return Int(INT_MAX)
        case .none:
            return 0
        }
    }
    var isHeadLine: Bool {
        switch self {
        case .headLine(_):
            return true
        default:
            return false
        }
    }
}

func <= (left: LineType, right: LineType) -> Bool { return left.level <= right.level }
func >= (left: LineType, right: LineType) -> Bool { return left.level >= right.level }

class Node {
    let childs = [Node]()
    let parent: Node?
    let type: LineType
    let line: String

    init(parent: Node?, type: LineType, line: String){
        self.parent = parent
        self.type = type
        self.line = line
        parent?.childs.append(self)
    }
}

func extractText(text: String, hierarchy: [String], options: [Option:[String]]) -> String {
    let root = createTree(text: text, options: options)
    guard let nodes = checkStructure(rootNode: root, hierarchy: hierarchy) else { return "" }
    var str = ""
    for node in nodes {
        str += getStringWith(rootNode: node)
    }
    return str
}
func createTree(text: String, options: [Option:[String]]) -> Node {
    var current = Node(parent: nil, type: .none, line: "")
    let root = current

    let disabledTabOption = (options[ConsoleOption.tab.option] == nil)
    let disabledEmptyLineOption = (options[ConsoleOption.emptyline.option] == nil)

    text.enumerateLines(invoking: { line, stop in
        let trimmedLine = disabledTabOption ? line.trimmingCharacters(in: .whitespaces) : line
        if disabledEmptyLineOption && trimmedLine.isEmpty { return }

        let type: LineType = trimmedLine.headLineLevel == 0 ? .content : .headLine(trimmedLine.headLineLevel)

        while current.type >= type { current = current.parent! }
        current = Node(parent: current, type: type, line: trimmedLine)
    })
    return root
}
func checkStructure(rootNode: Node, hierarchy: [String]) -> [Node]? {
    var hierarchy = hierarchy
    var nodes = [rootNode]

    while hierarchy.count > 0 {
        for node in nodes {
            nodes = node.childs.filter { $0.type.isHeadLine && $0.line.planeText == hierarchy.first }
            if nodes.count == 0 { return nil }
            hierarchy.remove(at: 0)
        }
    }
    return nodes
}
func getStringWith(rootNode: Node) -> String {
    var str = ""
    for child in rootNode.childs {
        str += child.line + "\n"
        str += getStringWith(rootNode: child)
    }
    return str
}

// md-tree -f filename.md 大見出し 中見出し 小見出し
private func main(arguments: [String]) {
    let arguments = arguments.dropFirst()

    let parser = OptionParser(definitions: [ConsoleOption.file.option, ConsoleOption.tab.option, ConsoleOption.emptyline.option])

    do {
        let (options, _) = try parser.parse(parameters: Array(arguments))
        if let filePath = options[ConsoleOption.file.option]?.first {
            let absolutePath = NSString(string: filePath).expandingTildeInPath
            let fileContent = try String(contentsOfFile: absolutePath, encoding: String.Encoding.utf8)
            let filteredArgs = arguments.filter { $0 != "-" + String(ConsoleOption.tab.flag.0) && $0 != "-" + ConsoleOption.tab.flag.1 }
                                        .filter { $0 != "-" + String(ConsoleOption.emptyline.flag.0) && $0 != "-" + ConsoleOption.emptyline.flag.1 }

            let hierarchy = Array(filteredArgs.dropFirst(2))
            if hierarchy.count == 0 { exit(0) }

            print(extractText(text: fileContent, hierarchy: hierarchy, options: options))
        }
    } catch let OptionKitError.InvalidOption(description: description) {
        print(description)
        exit(EXIT_FAILURE)
    } catch {
        exit(0)
    }
}

main(arguments: CommandLine.arguments)
