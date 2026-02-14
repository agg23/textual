import SwiftUI

extension StructuredText {
  /// The default paragraph style used by ``StructuredText/DefaultStyle``.
  public struct DefaultParagraphStyle: ParagraphStyle {
    /// Creates the default paragraph style.
    public init() {}

    public var blockSpacing: FontScaled<BlockSpacing> {
      .scaled(top: 0.8)
    }

    public func makeBody(configuration: Configuration) -> some View {
      configuration.label
        .textual.lineSpacing(.scaled(0.23))
    }
  }
}

extension StructuredText.ParagraphStyle where Self == StructuredText.DefaultParagraphStyle {
  /// The default paragraph style.
  public static var `default`: Self {
    .init()
  }
}

@available(tvOS, unavailable)
@available(watchOS, unavailable)
#Preview {
  StructuredText(
    markdown: """
      The sky above the port was the color of television,
      tuned to a dead channel.

      It was a bright cold day in April, and the clocks were
      striking thirteen.
      """
  )
  .padding()
  .textual.textSelection(.enabled)
}
