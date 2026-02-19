import SwiftUI

// MARK: - Overview
//
// BlockVStack arranges blocks vertically with CSS-style margin collapsing behavior. Adjacent
// blocks' top and bottom spacing collapses by taking the maximum value rather than summing,
// matching how CSS margins work.
//

extension StructuredText {
  struct BlockVStack<Content: View>: View {
    @Environment(\.multilineTextAlignment) private var textAlignment

    private let spacings: [BlockSpacing]
    private let content: Content

    init(spacings: [BlockSpacing], @ViewBuilder content: () -> Content) {
      self.spacings = spacings
      self.content = content()
    }

    var body: some View {
      Group(subviews: content) { children in
        BlockVStackLayout(
          textAlignment: textAlignment,
          spacings: spacings
        ) {
          ForEach(children) { $0 }
        }
      }
    }
  }
}

extension StructuredText {
  struct BlockAlignmentKey: LayoutValueKey {
    static let defaultValue: TextAlignment? = nil
  }

  fileprivate struct BlockVStackLayout: Layout {
    struct Cache {
      let spacings: [CGFloat]
      var sizes: [CGSize] = []
    }

    let textAlignment: TextAlignment
    let spacings: [BlockSpacing]

    func makeCache(subviews: Subviews) -> Cache {
      return Cache(
        spacings: spacings.indices.dropLast().map { index in
          let currentBottom = spacings[index].bottom
          let nextTop = spacings[index + 1].top
          return [currentBottom, nextTop].compactMap(\.self).max() ?? 0
        }
      )
    }

    func sizeThatFits(
      proposal: ProposedViewSize,
      subviews: Subviews, cache: inout Cache
    ) -> CGSize {
      if let width = proposal.width, width <= 0 {
        return .zero
      }

      var size = CGSize.zero
      var sizes: [CGSize] = []
      sizes.reserveCapacity(subviews.count)

      for view in subviews {
        let viewSize = view.sizeThatFits(.init(width: proposal.width, height: nil))
        sizes.append(viewSize)
        size.height += viewSize.height
        size.width = max(size.width, viewSize.width)
      }

      size.height += cache.spacings.reduce(0, +)
      cache.sizes = sizes

      return size
    }

    func placeSubviews(
      in bounds: CGRect,
      proposal: ProposedViewSize,
      subviews: Subviews, cache: inout Cache
    ) {
      var currentY: CGFloat = 0

      for (index, view) in zip(subviews.indices, subviews) {
        let viewProposal = ProposedViewSize(width: proposal.width, height: nil)
        let viewSize = cache.sizes.indices.contains(index)
          ? cache.sizes[index]
          : view.sizeThatFits(viewProposal)

        var point = bounds.origin
        let alignment = view[BlockAlignmentKey.self] ?? textAlignment

        switch alignment {
        case .leading:
          break  // do nothing
        case .center:
          point.x += (bounds.width - viewSize.width) / 2
        case .trailing:
          point.x += bounds.width - viewSize.width
        }

        point.y += currentY

        view.place(at: point, proposal: viewProposal)

        currentY += viewSize.height

        if index < subviews.count - 1 {
          currentY += cache.spacings[index]
        }
      }
    }
  }
}

@available(tvOS, unavailable)
@available(watchOS, unavailable)
#Preview {
  @Previewable @State var textAlignment = TextAlignment.leading
  @Previewable @State var blockSpacing: CGFloat = 1

  VStack {
    GroupBox {
      Picker("Text Alignment", selection: $textAlignment) {
        Text("Leading").tag(TextAlignment.leading)
        Text("Center").tag(TextAlignment.center)
        Text("Trailing").tag(TextAlignment.trailing)
      }
      .pickerStyle(.segmented)
      HStack {
        Text("2nd / 3rd Spacing")
        Slider(value: $blockSpacing, in: 0...3)
      }
    }
    Spacer()
    StructuredText.BlockVStack(spacings: [
      .init(top: 0, bottom: 16),
      .init(top: 0, bottom: blockSpacing * 16),
      .init(top: 16, bottom: 16),
    ]) {
      Text(
        """
        Listen to your sister, Morty. To live is to risk it all, otherwise you're just an inert \
        chunk of randomly assembled molecules drifting wherever the universe blows you.
        """
      )
      Text(
        """
        Listen, Morty, I hate to break it to you but what people call "love" is just a chemical \
        reaction that compels animals to breed. It hits hard, Morty, then it slowly fades, \
        leaving you stranded in a failing marriage. I did it. Your parents are gonna do it. \
        Break the cycle, Morty. Rise above. Focus on science.
        """
      )
      Text(
        """
        Wow, I really Cronenberged up the whole place, huh Morty? Just a bunch a Cronenbergs \
        walkin' around.
        """
      )
    }
    .border(Color.red)
    Spacer()
  }
  .multilineTextAlignment(textAlignment)
  .padding()
}
