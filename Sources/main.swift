import Foundation
import OptionKit

enum LineType {
    case headLine(Int)
    case content
    case none
    
    func level() -> Int {
        switch self {
        case .headLine(let headLevel):
            return headLevel
        case .content:
            return Int(INT_MAX)
        case .none:
            return 0
        }
    }
}
class Node {
    let childs = [Node]()
    let parent:Node?
    let type: LineType
    let line: String
    
    init(parent: Node?, type:LineType, line:String){
        self.parent = parent
        self.type = type
        self.line = line
        parent?.childs.append(self)
    }
}
func <= (left:LineType, right:LineType) -> Bool { return left.level() <= right.level() }
func >= (left:LineType, right:LineType) -> Bool { return left.level() >= right.level() }

// md-tree -f filename.md 大見出し 中見出し 小見出し
private func main(arguments: [String]) {
    let arguments = arguments.dropFirst()

    let fileOption = Option(trigger: OptionTrigger.Mixed("f", "filename"), numberOfParameters: 1, helpDescription: "Markdown file")
    let parser = OptionParser(definitions: [fileOption])

    do {
        let (options, _) = try parser.parse(parameters: Array(arguments))
        if let filePath = options[fileOption]?.first {
            print(filePath)
            let location = NSString(string: filePath).expandingTildeInPath
            let fileContent = try String(contentsOfFile: location, encoding: String.Encoding.utf8)
            let hierarchy = Array(arguments.dropFirst(2))

            _ = extract(text: fileContent,hierarchy: hierarchy)
        }
    } catch let OptionKitError.InvalidOption(description: description) {
        print(description)
        exit(EXIT_FAILURE)
    } catch {
        exit(0)
    }
}

func extract(text: String, hierarchy: [String]) -> String{
    var current = Node(parent: nil, type: .none, line: "")
    let root = current
    text.enumerateLines(invoking: { line, stop in
        let trimmedLine = line.trimmingCharacters(in: .whitespaces)
        if trimmedLine.isEmpty { return }
        let type:LineType = trimmedLine.headLineLevel() == 0 ? .content : .headLine(trimmedLine.headLineLevel())
        
        while(current.type >= type){ current = current.parent! }
        current = Node(parent: current, type: type, line: trimmedLine)
    })
    
    show(node: root)
    return ""
}
func show(node:Node){
    for child in node.childs {
        print(child.line)
        show(node: child)
    }
}

main(arguments: CommandLine.arguments)
