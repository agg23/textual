import SwiftUI

// MARK: - Overview
//
// `TextSelectionInteraction` manages the text selection model lifecycle for multiple `Text` fragments.
//
// Selection is opt-in through the `textSelection` environment value. When enabled, the modifier
// observes text layout changes via `overlayTextLayoutCollection` and creates or updates a
// `TextSelectionModel`. The model is then passed to the platform-specific implementation
// (`PlatformTextSelectionInteraction`), which presents the appropriate selection UI for macOS
// or iOS. This separation keeps model management in shared code while platform interactions
// remain independent.

struct TextSelectionInteraction: ViewModifier {
  #if TEXTUAL_ENABLE_TEXT_SELECTION
    @Environment(\.textSelection) private var textSelection
    @Environment(\.textSelectionLayoutActive) private var textSelectionLayoutActive
    @Environment(TextSelectionCoordinator.self) private var coordinator: TextSelectionCoordinator?

    @State private var model = TextSelectionModel()
  #endif

  func body(content: Content) -> some View {
    #if TEXTUAL_ENABLE_TEXT_SELECTION
      if textSelection.allowsSelection {
        content
          .overlayPreferenceValue(Text.LayoutKey.self) { value in
            // Can't conditionally apply `overlayPreferenceValue`, so at least conditionally apply the inner work
            if textSelectionLayoutActive {
              GeometryReader { geometry in
                Color.clear
                  .onChange(of: AnyTextLayoutCollection(
                    LiveTextLayoutCollection(base: value, geometry: geometry)
                  ), initial: true) {
                    model.setCoordinator(coordinator)
                    model.setLayoutCollection(
                      LiveTextLayoutCollection(base: value, geometry: geometry)
                    )
                  }
              }
            } else {
              Color.clear
            }
          }
          .modifier(PlatformTextSelectionInteraction(model: model))
      } else {
        content
      }
    #else
      content
    #endif
  }
}

#if TEXTUAL_ENABLE_TEXT_SELECTION
  extension EnvironmentValues {
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @usableFromInline
    @Entry var textSelection: any TextSelectability.Type = DisabledTextSelectability.self

    @Entry public var textSelectionLayoutActive: Bool = true
  }
#endif
