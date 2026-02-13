import SwiftUI

extension StructuredText {
  struct BlockSpacingKey: PreferenceKey, LayoutValueKey {
    // Default to 0/0 to prevent BlockVStackLayout.makeCache from hitting the expensive
    // LayoutSubview.spacing.distance(to:along:) fallback on the first layout pass,
    // before onPreferenceChange has fired to populate the real values
    static let defaultValue = BlockSpacing(top: 0, bottom: 0)

    static func reduce(value: inout BlockSpacing, nextValue: () -> BlockSpacing) {
      value = value.union(nextValue())
    }
  }
}
