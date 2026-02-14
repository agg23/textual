import SwiftUI

extension StructuredText {
  /// A style that controls how `StructuredText` renders thematic breaks.
  ///
  /// You can apply a thematic break style using the ``TextualNamespace/thematicBreakStyle(_:)`` modifier
  /// or through a bundled ``StructuredText/Style``.
  public protocol ThematicBreakStyle: DynamicProperty {
    associatedtype Body: View

    /// Creates a view that represents a thematic break.
    @MainActor @ViewBuilder func makeBody(configuration: Self.Configuration) -> Self.Body

    /// The block spacing to apply above and below thematic breaks.
    var blockSpacing: FontScaled<BlockSpacing> { get }

    typealias Configuration = BlockStyleConfiguration
  }
}

extension StructuredText.ThematicBreakStyle {
  /// Default block spacing.
  public var blockSpacing: FontScaled<StructuredText.BlockSpacing> {
    .scaled(top: 0, bottom: 0)
  }
}

extension EnvironmentValues {
  @usableFromInline
  @Entry var thematicBreakStyle: any StructuredText.ThematicBreakStyle = .divider
}
