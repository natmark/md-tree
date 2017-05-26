import Foundation
import OptionKit

enum LineType {
    case headLine
    case content
}
class Node {
    let childs = [Node]()
    let parent:Node?
    
    var type: LineType? = nil
    var line: String = ""
    
    init(parent: Node?){
        self.parent = parent
        parent?.childs.append(self)
    }
}
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
    var current = Node(parent: nil)
    
    text.enumerateLines(invoking: { line, stop in
        let trimmedLine = line.trimmingCharacters(in: .whitespaces)
        if trimmedLine.isEmpty { return }
        let type:LineType = trimmedLine.headLineLevel() == 0 ? .content : .headLine
    })
    return ""
}

main(arguments: CommandLine.arguments)
