import UITestingTool
import XCTest

final class XCUITestDriver: Driver {

    private(set) var element: XCUIElement!

    let app: XCUIApplication
    private let interactionElementWorkers: [(Interaction.Type, InteractionElementWorker.Type)]
    private let interactionWorkers: [(Interaction.Type, InteractionWorker.Type)]

    init(app: XCUIApplication, interactionElementWorkers: [(Interaction.Type, InteractionElementWorker.Type)], interactionWorkers: [(Interaction.Type, InteractionWorker.Type)]) {
        let defaultInteractionElementWorkers: [(Interaction.Type, InteractionElementWorker.Type)] = [
            (AccessibilityElementInteraction.self, AccessibilityElementInteractionWorker.self),
            (TextElementInteraction.self, TextElementInteractionWorker.self)
        ]
        let defaultInteractionWorkers: [(Interaction.Type, InteractionWorker.Type)] = [
            (ValueInteraction.self, ValueInteractionWorker.self),
            (VisibilityAssertInteraction.self, VisibilityAssertInteractionWorker.self),
            (WaitInteraction.self, WaitInteractionWorker.self),
            (TextAssertInteraction.self, TextAssertInteractionWorker.self),
            (TapActionInteraction.self, TapActionInteractionWorker.self),
            (LongPressInteraction.self, LongPressInteractionWorker.self),
            (EnabledAssertInteraction.self, EnabledAssertInteractionWorker.self),
            (ToggleAssertInteraction.self, ToggleAssertInteractionWorker.self),
            (KeyboardInteraction.self, KeyboardInteractionWorker.self),
            (SlideActionInteraction.self, SlideActionInteractionWorker.self),
            (SelectedAssertInteraction.self, SelectedAssertInteractionWorker.self),
            (ScrollActionInteraction.self, ScrollActionInteractionWorker.self),
            (PickerWheelInteraction.self, PickerWheelInteractionWorker.self)
        ]
        self.app = app
        self.interactionElementWorkers = interactionElementWorkers + defaultInteractionElementWorkers
        self.interactionWorkers = interactionWorkers + defaultInteractionWorkers
    }

    init(interactionElementWorkers: [(Interaction.Type, InteractionElementWorker.Type)], interactionWorkers: [(Interaction.Type, InteractionWorker.Type)]) {
        fatalError("User init with XCUIApplication")
    }

    func execute(_ interaction: Interaction) {
        switch interaction {
        case is ElementInteraction:
            element = element(for: interaction)
        default:
            handle(interaction)
        }
    }

    private func element(for interaction: Interaction) -> XCUIElement {
        for item in interactionElementWorkers {
            let typeA = "\(Swift.type(of: interaction))"
            let typeB = "\(item.0)"

            guard typeA == typeB else { continue }
            let worker = item.1.init(driver: self)
            let element = worker.element(for: interaction)
            guard let castedElement = element as? XCUIElement else {
                Assert.fail("Element \(Swift.type(of: element)) cannot be converted to XCUIElement", in: interaction.context)
                fatalError()
            }
            return castedElement
        }
        Assert.fail("There is no element worker mapped for this interaction", in: interaction.context)
        fatalError()
    }

    private func handle(_ interaction: Interaction) {
        var isInteractionHandled = false
        for item in interactionWorkers {
            let typeA = "\(Swift.type(of: interaction))"
            let typeB = "\(item.0)"

            guard typeA == typeB else { continue }

            let worker = item.1.init(driver: self)
            worker.execute(interaction)
            isInteractionHandled = true
            break
        }
        Assert.true(isInteractionHandled, "There is no worker mapped for this interaction \(interaction)", in: interaction.context)
    }
}