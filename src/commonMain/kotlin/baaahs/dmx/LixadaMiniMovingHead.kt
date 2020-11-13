package baaahs.dmx

import baaahs.Color
import baaahs.model.MovingHead
import baaahs.toRadians

class LixadaMiniMovingHead(override val buffer: Dmx.Buffer) : Dmx.Adapter, MovingHead.Buffer {
    override val panChannel get() = Channel.PAN
    override val panFineChannel: Dmx.Channel? get() = null /*Channel.PAN_FINE*/
    override val tiltChannel: Dmx.Channel get() = Channel.TILT
    override val tiltFineChannel: Dmx.Channel? get() = null /*Channel.TILT_FINE*/
    override val dimmerChannel: Dmx.Channel get() = Channel.DIMMER
    override var color: Color
        get() = Color(buffer[Channel.RED], buffer[Channel.GREEN], buffer[Channel.BLUE])
        set(value) {
            buffer[Channel.RED] = value.redI.toByte()
            buffer[Channel.GREEN] = value.greenI.toByte()
            buffer[Channel.BLUE] = value.blueI.toByte()
        }

    override val colorMode: MovingHead.ColorMode get() = MovingHead.ColorMode.RGBW
    override val colorWheelColors: List<Shenzarpy.WheelColor>
        get() = throw UnsupportedOperationException()

    override val panRange: ClosedRange<Float> =
        toRadians(0f)..toRadians(540f)
    override val tiltRange: ClosedRange<Float> =
        toRadians(-110f)..toRadians(110f)

    init {
        dimmer = 134 * 256 / 65535f
        buffer[Channel.WHITE] = 255.toByte()
        buffer[Channel.RED] = 255.toByte()
        buffer[Channel.GREEN] = 255.toByte()
        buffer[Channel.BLUE] = 255.toByte()
    }

    enum class Channel: Dmx.Channel {
        PAN,
//        PAN_FINE,
        TILT,
//        TILT_FINE,
        DIMMER,
        RED,
        GREEN,
        BLUE,
        WHITE,
        PAN_TILT_SPEED,
//        COLOR_11,
//        COLOR_12,
//        COLOR_CONTROL,
        COLOR_RESET;

        override val offset = ordinal
    }

    companion object : Dmx.AdapterBuilder {
        override fun build(buffer: Dmx.Buffer) = LixadaMiniMovingHead(buffer)
    }
}