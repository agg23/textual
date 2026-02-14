import SwiftUI

extension StructuredText {
  struct UnorderedList: View {
    @Environment(\.listItemSpacing) private var listItemSpacing
    @Environment(\.textEnvironment) private var textEnvironment

    private let intent: PresentationIntent.IntentType?
    private let content: AttributedSubstring

    init(intent: PresentationIntent.IntentType?, content: AttributedSubstring) {
      self.intent = intent
      self.content = content
    }

    var body: some View {
      let runs = content.blockRuns(parent: intent)
      let resolvedSpacing = listItemSpacing.resolve(in: textEnvironment)

      let spacings = Array(repeating: resolvedSpacing, count: runs.count)

      BlockVStack(spacings: spacings) {
        ForEach(runs.indices, id: \.self) { index in
          let run = runs[index]

          UnorderedListItem(
            intent: run.intent,
            content: content[run.range]
          )
        }
      }
    }
  }
}

extension StructuredText {
  fileprivate struct UnorderedListItem: View {
    @Environment(\.listItemStyle) private var listItemStyle
    @Environment(\.unorderedListMarker) private var unorderedListMarker

    private let intent: PresentationIntent.IntentType?
    private let content: AttributedSubstring

    init(
      intent: PresentationIntent.IntentType?,
      content: AttributedSubstring
    ) {
      self.intent = intent
      self.content = content
    }

    var body: some View {
      let configuration = ListItemStyleConfiguration(
        marker: .init(marker),
        block: .init(
          BlockContent(
            parent: intent,
            content: content
          )
        ),
        indentationLevel: indentationLevel
      )
      let resolvedStyle = listItemStyle.resolve(configuration: configuration)

      AnyView(resolvedStyle)
    }

    private var marker: some View {
      AnyView(
        unorderedListMarker.resolve(
          configuration: .init(
            indentationLevel: indentationLevel
          )
        )
      )
    }

    private var indentationLevel: Int {
      content.runs.first?.presentationIntent?.indentationLevel ?? 0
    }
  }
}
