package baaahs.plugin.core.feed

import baaahs.Color
import baaahs.ShowPlayer
import baaahs.control.MutableColorPickerControl
import baaahs.gadgets.ColorPicker
import baaahs.gl.GlContext
import baaahs.gl.data.EngineFeedContext
import baaahs.gl.data.FeedContext
import baaahs.gl.data.ProgramFeedContext
import baaahs.gl.data.SingleUniformFeedContext
import baaahs.gl.glsl.GlslProgram
import baaahs.gl.glsl.GlslType
import baaahs.gl.patch.ContentType
import baaahs.gl.shader.InputPort
import baaahs.plugin.classSerializer
import baaahs.plugin.core.CorePlugin
import baaahs.show.Feed
import baaahs.show.FeedBuilder
import baaahs.show.mutable.MutableControl
import baaahs.util.Logger
import baaahs.util.RefCounted
import baaahs.util.RefCounter
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.contentOrNull
import kotlinx.serialization.json.jsonPrimitive

@Serializable
@SerialName("baaahs.Core:ColorPicker")
data class ColorPickerFeed(
    @SerialName("title")
    val colorPickerTitle: String,
    val initialValue: Color
) : Feed {
    override val title: String get() = "$colorPickerTitle Color Picker"

    override fun buildControl(): MutableControl {
        return MutableColorPickerControl(colorPickerTitle, initialValue, this)
    }

    override fun open(showPlayer: ShowPlayer, id: String): FeedContext {
//        val channel = showPlayer.useChannel<Float>(id)
        val colorPicker = showPlayer.useGadget(this)
            ?: showPlayer.useGadget(id)
            ?: run {
                logger.debug { "No control gadget registered for feed $id, creating one. This is probably busted." }
                createGadget()
            }

        return object : FeedContext, RefCounted by RefCounter() {
            override fun bind(gl: GlContext): EngineFeedContext = object : EngineFeedContext {
                override fun bind(glslProgram: GlslProgram): ProgramFeedContext {
                    return SingleUniformFeedContext(glslProgram, this@ColorPickerFeed, id) { uniform ->
                        val color = colorPicker.color
                        uniform.set(color.redF, color.greenF, color.blueF, color.alphaF)
                    }
                }
            }
        }
    }

    companion object : FeedBuilder<ColorPickerFeed> {
        override val title: String get() = "Color Picker"
        override val description: String get() = "A user-adjustable color picker."
        override val resourceName: String get() = "ColorPicker"
        override val contentType: ContentType get() = ContentType.Color
        override val serializerRegistrar get() = classSerializer(serializer())

        override fun build(inputPort: InputPort): ColorPickerFeed {
            val default = inputPort.pluginConfig?.get("default")?.jsonPrimitive?.contentOrNull

            return ColorPickerFeed(
                inputPort.title,
                initialValue = default?.let { Color.Companion.from(it) } ?: Color.WHITE
            )
        }

        private val logger = Logger<ColorPickerFeed>()
    }

    override val pluginPackage: String get() = CorePlugin.id
    override fun getType(): GlslType = GlslType.Vec4
    override val contentType: ContentType
        get() = ContentType.Color

    fun createGadget(): ColorPicker = ColorPicker(colorPickerTitle, initialValue)
}