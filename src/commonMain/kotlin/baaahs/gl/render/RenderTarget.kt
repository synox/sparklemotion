package baaahs.gl.render

import baaahs.fixtures.Fixture
import baaahs.gl.glsl.GlslProgram
import baaahs.gl.result.ResultStorage
import baaahs.visualizer.remote.RemoteVisualizers

interface RenderTarget {
    val fixture: Fixture
    val componentCount: Int

    fun sendFrame(remoteVisualizers: RemoteVisualizers)
    fun release()
}

class FixtureRenderTarget(
    override val fixture: Fixture,
    val rect0Index: Int,
    val rects: List<Quad.Rect>, // these are in pixels, (0,0) at top left
    override val componentCount: Int,
    val component0Index: Int,
    resultStorage: ResultStorage
) : RenderTarget {
    var program: GlslProgram? = null
        private set

    val fixtureResults = resultStorage.getFixtureResults(fixture, component0Index)

    override fun sendFrame(remoteVisualizers: RemoteVisualizers) {
        fixtureResults.send(remoteVisualizers)
    }

    override fun release() {
        program = null
    }

    /** Only call me from [RenderEngine]! */
    internal fun usingProgram(program: GlslProgram?) {
        this.program = program
    }

    override fun toString(): String {
        return "RenderTarget(fixture=$fixture, rect0Index=$rect0Index, rects=$rects, pixel0Index=$component0Index)"
    }
}