import SwiftUI

extension StructuredText {
  /// The properties of a table passed to a `TableStyle`.
  public struct TableStyleConfiguration {
    /// A type-erased view that contains the table content.
    public struct Label: View {
      init(_ label: some View) {
        self.body = AnyView(label)
      }
      public let body: AnyView
    }

    /// The table content.
    public let label: Label

    /// The indentation level of the table within the document structure.
    public let indentationLevel: Int
  }

  /// A style that controls how `StructuredText` renders tables.
  ///
  /// You can apply a table style using the ``TextualNamespace/tableStyle(_:)`` modifier
  /// or through a bundled ``StructuredText/Style``.
  public protocol TableStyle: DynamicProperty {
    associatedtype Body: View

    /// Creates a view that represents a table.
    @MainActor @ViewBuilder
    func makeBody(configuration: Self.Configuration) -> Self.Body

    /// The block spacing to apply above and below tables.
    var blockSpacing: FontScaled<BlockSpacing> { get }

    typealias Configuration = TableStyleConfiguration
  }
}

extension StructuredText.TableStyle {
  /// Default block spacing.
  public var blockSpacing: FontScaled<StructuredText.BlockSpacing> {
    .scaled(top: 0, bottom: 0)
  }
}

extension EnvironmentValues {
  @usableFromInline
  @Entry var tableStyle: any StructuredText.TableStyle = .default
}
