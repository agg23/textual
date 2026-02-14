import SwiftUI

extension StructuredText {
  struct BlockContent<Content: AttributedStringProtocol>: View {
    @Environment(\.textEnvironment) private var textEnvironment
    @Environment(\.paragraphStyle) private var paragraphStyle
    @Environment(\.headingStyle) private var headingStyle
    @Environment(\.codeBlockStyle) private var codeBlockStyle
    @Environment(\.blockQuoteStyle) private var blockQuoteStyle
    @Environment(\.thematicBreakStyle) private var thematicBreakStyle
    @Environment(\.tableStyle) private var tableStyle

    private let parent: PresentationIntent.IntentType?
    private let content: Content

    init(parent: PresentationIntent.IntentType? = nil, content: Content) {
      self.parent = parent
      self.content = content
    }

    var body: some View {
      let runs = content.blockRuns(parent: parent)

      let spacings = runs.map { run -> BlockSpacing in
        blockSpacingForRun(run)
      }

      BlockVStack(spacings: spacings) {
        ForEach(runs.indices, id: \.self) { index in
          let run = runs[index]
          Block(intent: run.intent, content: content[run.range])
        }
      }
    }

    private func blockSpacingForRun(_ run: AttributedString.BlockRuns.BlockRun) -> BlockSpacing {
      let fontScaledSpacing: FontScaled<BlockSpacing>

      switch run.intent?.kind {
      case .paragraph:
        fontScaledSpacing = paragraphStyle.blockSpacing
      case .header:
        fontScaledSpacing = headingStyle.blockSpacing
      case .codeBlock:
        fontScaledSpacing = codeBlockStyle.blockSpacing
      case .blockQuote:
        fontScaledSpacing = blockQuoteStyle.blockSpacing
      case .thematicBreak:
        fontScaledSpacing = thematicBreakStyle.blockSpacing
      case .table:
        fontScaledSpacing = tableStyle.blockSpacing
      case .orderedList, .unorderedList:
        // Lists set their own block spacing (top: 0.8 font-scaled)
        fontScaledSpacing = .scaled(top: 0.8)
      default:
        // Fallback to paragraph spacing for unknown block types
        fontScaledSpacing = paragraphStyle.blockSpacing
      }

      return fontScaledSpacing.resolve(in: textEnvironment)
    }
  }
}

extension StructuredText {
  struct Block: View {
    private let intent: PresentationIntent.IntentType?
    private let content: AttributedSubstring

    init(intent: PresentationIntent.IntentType?, content: AttributedSubstring) {
      self.intent = intent
      self.content = content
    }

    var body: some View {
      switch intent?.kind {
      case .paragraph where content.isMathBlock:
        MathBlock(content)
      case .paragraph:
        Paragraph(content)
      case .header(let level):
        Heading(content, level: level)
      case .orderedList:
        OrderedList(intent: intent, content: content)
      case .unorderedList:
        UnorderedList(intent: intent, content: content)
      case .codeBlock(let languageHint) where languageHint?.lowercased() == "math":
        MathCodeBlock(content)
      case .codeBlock(let languageHint):
        CodeBlock(content, languageHint: languageHint)
      case .blockQuote:
        BlockQuote(intent: intent, content: content)
      case .thematicBreak:
        ThematicBreak(content)
      case .table(let columns):
        Table(intent: intent, content: content, columns: columns)
      default:
        Paragraph(content)
      }
    }
  }
}
