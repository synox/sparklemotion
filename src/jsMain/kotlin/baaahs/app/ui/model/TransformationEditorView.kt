package baaahs.app.ui.model

import baaahs.app.ui.appContext
import baaahs.geom.EulerAngle
import baaahs.geom.Vector3F
import baaahs.geom.toThreeEuler
import baaahs.scene.EditingEntity
import baaahs.ui.unaryMinus
import baaahs.ui.xComponent
import baaahs.visualizer.toVector3
import kotlinx.html.unsafe
import kotlinx.js.jso
import mui.material.Container
import react.*
import react.dom.header
import react.dom.span

private val TransformationEditorView = xComponent<TransformationEditorProps>("TransformationEditor") { props ->
    val appContext = useContext(appContext)
    val styles = appContext.allStyles.modelEditor

    observe(props.editingEntity)
    observe(props.editingEntity.affineTransforms)
    val mutableEntity = props.editingEntity.mutableEntity
    val entityVisualizer = props.editingEntity.itemVisualizer

    val handlePositionChange by handler(entityVisualizer, mutableEntity) { value: Vector3F ->
        entityVisualizer.obj.position.copy(value.toVector3())
        mutableEntity.position = value
        props.editingEntity.onChange()
    }

    val handleRotationChange by handler(entityVisualizer, mutableEntity) { value: EulerAngle ->
        entityVisualizer.obj.rotation.copy(value.toThreeEuler())
        mutableEntity.rotation = value
        props.editingEntity.onChange()
    }

    val handleScaleChange by handler(entityVisualizer, mutableEntity) { value: Vector3F ->
        entityVisualizer.obj.scale.copy(value.toVector3())
        mutableEntity.scale = value
        props.editingEntity.onChange()
    }


    header { +"Transformation" }
    Container {
        attrs.classes = jso { this.root = -styles.transformEditSection }
        header { +"Position:" }

        vectorEditor {
            attrs.vector3F = mutableEntity.position
            attrs.adornment = buildElement { +props.editingEntity.modelUnit.display }
            attrs.onChange = handlePositionChange
        }
    }

    Container {
        attrs.classes = jso { this.root = -styles.transformEditSection }
        header { +"Rotation:" }

        rotationEditor {
            attrs.eulerAngle = mutableEntity.rotation
            attrs.onChange = handleRotationChange
        }
    }

    Container {
        attrs.classes = jso { this.root = -styles.transformEditSection }
        header { +"Scale:" }

        vectorEditor {
            attrs.vector3F = mutableEntity.scale
            attrs.adornment = buildElement {
                span {
//                    attrs.entity(Entities.times)
                    attrs.unsafe { +"&#xd7;" }
                }
            }
            attrs.onChange = handleScaleChange
        }
    }
}

external interface TransformationEditorProps : Props {
    var editingEntity: EditingEntity<*>
}

fun RBuilder.transformationEditor(handler: RHandler<TransformationEditorProps>) =
    child(TransformationEditorView, handler = handler)