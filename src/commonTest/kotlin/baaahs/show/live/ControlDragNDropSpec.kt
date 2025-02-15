package baaahs.show.live

import baaahs.control.OpenButtonGroupControl
import baaahs.getBang
import baaahs.gl.override
import baaahs.show.Panel
import baaahs.show.mutable.MutablePanel
import baaahs.show.mutable.MutableShow
import baaahs.show.mutable.ShowBuilder
import baaahs.shows.FakeShowPlayer
import baaahs.toBeSpecified
import baaahs.ui.Draggable
import baaahs.ui.DropTarget
import baaahs.unknown
import ch.tutteli.atrium.api.fluent.en_GB.containsExactly
import ch.tutteli.atrium.api.fluent.en_GB.toBe
import ch.tutteli.atrium.api.verbs.expect
import org.spekframework.spek2.Spek
import org.spekframework.spek2.style.specification.describe

object ControlDragNDropSpec : Spek({
    describe("Control Drag & Drop") {
        val panel1 by value { MutablePanel(Panel("Panel 1"))}
        val mutableShow by value {
            MutableShow("Show")
                .editLayouts {
                    panels["panel1"] = panel1
                    panels["panel2"] = MutablePanel(Panel("Panel 2"))
                    panels["panel3"] = MutablePanel(Panel("Panel 3"))
                }
        }
        val show by value { mutableShow.build(ShowBuilder()) }

        val showPlayer by value { FakeShowPlayer() }
        val openShow by value { showPlayer.openShow(show) }
        val editHandler by value { FakeEditHandler() }
        val dragNDrop by value { FakeDragNDrop<Int>() }
        val controlDisplay by value { LegacyControlDisplay(openShow, editHandler, dragNDrop) }

        fun renderEditedShow(): String {
            val editedOpenShow = showPlayer.openShow(editHandler.updatedShow, openShow.getShowState())
            val newControlDisplay = LegacyControlDisplay(editedOpenShow, editHandler, dragNDrop)
            return editedOpenShow.fakeRender(newControlDisplay)
        }

        beforeEachTest {
            mutableShow.addFixtureControls()
            mutableShow.addButton(panel1, "Button A") {}
            mutableShow.addButton(panel1, "Button B") {}
        }

        val panelBuckets by value {
            openShow.layouts.panels.mapValues { (_, panel) ->
                controlDisplay.renderBuckets(panel)
            }
        }

        fun findBucket(panelId: String, sectionTitle: String): LegacyControlDisplay.PanelBuckets.PanelBucket {
            val panelBucket = panelBuckets.getBang(panelId, "panel")
            return panelBucket.find { it.section.title == sectionTitle }
                ?: error(unknown("section", sectionTitle, panelBucket.map { it.section.title }))
        }

        val fromDropTarget by value { toBeSpecified<DropTarget<Int>>() }
        val toDropTarget by value { toBeSpecified<DropTarget<Int>>() }
        val draggedControl by value { toBeSpecified<Draggable<Int>>() }

        it("has the expected initial state") {
            expect(openShow.fakeRender(controlDisplay)).toBe(
                """
                    Panel 1:
                      |Show| scenes[*scene1*, scene2], buttonA, buttonB
                      |Scene 1|
                      |Backdrop 1.1|
                    Panel 2:
                      |Show|
                      |Scene 1| backdrops[*backdrop11*, backdrop12]
                      |Backdrop 1.1|
                    Panel 3:
                      |Show|
                      |Scene 1| slider1
                      |Backdrop 1.1|
                """.trimIndent()
            )
        }

        context("when a button is dragged") {
            override(fromDropTarget) { findBucket("panel1", "Show") }
            override(draggedControl) { fromDropTarget.getDraggable(1) }

            context("and dropped within the same DropTarget") {
                override(toDropTarget) { fromDropTarget }

                it("can be dropped back in the same bucket") {
                    expect(draggedControl.willMoveTo(toDropTarget)).toBe(true)
                    expect(toDropTarget.willAccept(draggedControl)).toBe(true)
                }

                it("reorders controls in the parent") {
                    dragNDrop.doMove(fromDropTarget, 1, fromDropTarget, 2)

                    expect(editHandler.updatedShow.controlLayout.getBang("panel1", "panels"))
                        .containsExactly("scenes", "buttonB", "buttonA")
                }
            }

            context("and dropped to another PanelBucket") {
                override(toDropTarget) { findBucket("panel1", "Scene 1") }

                it("can be dropped back into another bucket") {
                    expect(draggedControl.willMoveTo(toDropTarget)).toBe(true)
                    expect(toDropTarget.willAccept(draggedControl)).toBe(true)
                }

                it("removes the control from prior parent and adds it to the new parent") {
                    dragNDrop.doMove(fromDropTarget, 1, toDropTarget, 0)

                    expect(renderEditedShow()).toBe(
                        """
                            Panel 1:
                              |Show| scenes[*scene1*, scene2], buttonB
                              |Scene 1| buttonA
                              |Backdrop 1.1|
                            Panel 2:
                              |Show|
                              |Scene 1| backdrops[*backdrop11*, backdrop12]
                              |Backdrop 1.1|
                            Panel 3:
                              |Show|
                              |Scene 1| slider1
                              |Backdrop 1.1|
                        """.trimIndent()
                    )
                }
            }

            context("and dropped to a ButtonGroup") {
                override(toDropTarget) {
                    (openShow.allControls.find { it.id == "scenes" } as OpenButtonGroupControl)
                        .createDropTarget(controlDisplay)
                }

                it("can be dropped into a button group") {
                    expect(draggedControl.willMoveTo(toDropTarget)).toBe(true)
                    expect(toDropTarget.willAccept(draggedControl)).toBe(true)
                }

                it("removes the control from prior parent and adds it to the new parent") {
                    dragNDrop.doMove(fromDropTarget, 1, toDropTarget, 0)

                    expect(renderEditedShow()).toBe(
                        """
                            Panel 1:
                              |Show| scenes[buttonA, *scene1*, scene2], buttonB
                              |Scene 1|
                              |Backdrop 1.1|
                            Panel 2:
                              |Show|
                              |Scene 1| backdrops[*backdrop11*, backdrop12]
                              |Backdrop 1.1|
                            Panel 3:
                              |Show|
                              |Scene 1| slider1
                              |Backdrop 1.1|
                        """.trimIndent()
                    )
                }
            }

            context("from a ButtonGroup to a panel") {
                override(fromDropTarget) {
                    (openShow.allControls.find { it.id == "scenes" } as OpenButtonGroupControl)
                        .createDropTarget(controlDisplay)
                }
                override(toDropTarget) { findBucket("panel1", "Scene 1") }

                it("can be dropped") {
                    expect(draggedControl.willMoveTo(toDropTarget)).toBe(true)
                    expect(toDropTarget.willAccept(draggedControl)).toBe(true)
                }

                it("removes the control from prior parent and adds it to the new parent") {
                    dragNDrop.doMove(fromDropTarget, 1, toDropTarget, 0)

                    expect(renderEditedShow()).toBe(
                        """
                            Panel 1:
                              |Show| scenes[*scene1*], buttonA, buttonB
                              |Scene 1| scene2
                              |Backdrop 1.1|
                            Panel 2:
                              |Show|
                              |Scene 1| backdrops[*backdrop11*, backdrop12]
                              |Backdrop 1.1|
                            Panel 3:
                              |Show|
                              |Scene 1| slider1
                              |Backdrop 1.1|
                        """.trimIndent()
                    )
                }
            }
        }
    }
})