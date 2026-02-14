import SwiftUI

extension StructuredText {
  /// A style that controls how `StructuredText` renders paragraphs.
  ///
  /// You can set a paragraph style using the ``TextualNamespace/paragraphStyle(_:)`` modifier
  /// or through a bundled ``StructuredText/Style``.
  public protocol ParagraphStyle: DynamicProperty {
    associatedtype Body: View

    /// Creates a view that represents a paragraph.
    @MainActor @ViewBuilder func makeBody(configuration: Self.Configuration) -> Self.Body

    /// The block spacing to apply above and below paragraphs.
    var blockSpacing: FontScaled<BlockSpacing> { get }

    typealias Configuration = BlockStyleConfiguration
  }
}

extension StructuredText.ParagraphStyle {
  /// Default block spacing.
  public var blockSpacing: FontScaled<StructuredText.BlockSpacing> {
    .scaled(top: 0, bottom: 0)
  }
}

extension EnvironmentValues {
  @usableFromInline
  @Entry var paragraphStyle: any StructuredText.ParagraphStyle = .default
}
