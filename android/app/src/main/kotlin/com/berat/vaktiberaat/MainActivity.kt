package com.berat.vaktiberaat

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.view.Surface
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import kotlin.math.sqrt

class MainActivity : FlutterActivity(), SensorEventListener {
    private var sensorManager: SensorManager? = null
    private var rotationVectorSensor: Sensor? = null
    private var geomagRotationSensor: Sensor? = null
    private var accelSensor: Sensor? = null
    private var magSensor: Sensor? = null

    private var eventSink: EventChannel.EventSink? = null
    private var lastMagneticStrengthUt: Double = 46.5
    private var lastAccuracy: Int = SensorManager.SENSOR_STATUS_ACCURACY_HIGH

    private val gravity = FloatArray(3)
    private val geomagnetic = FloatArray(3)
    private var hasGravity = false
    private var hasGeomagnetic = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        sensorManager = getSystemService(Context.SENSOR_SERVICE) as? SensorManager
        rotationVectorSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        geomagRotationSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_GEOMAGNETIC_ROTATION_VECTOR)
        accelSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        magSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.vaktihuzur.app/compass_stream"
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                startCompassListeners()
            }

            override fun onCancel(arguments: Any?) {
                stopCompassListeners()
                eventSink = null
            }
        })
    }

    private fun startCompassListeners() {
        val sm = sensorManager ?: return
        // Her zaman manyetik alan şiddeti (µT) ve kalibrasyon durumu için TYPE_MAGNETIC_FIELD dinle
        magSensor?.let { sm.registerListener(this, it, SensorManager.SENSOR_DELAY_GAME) }

        if (rotationVectorSensor != null) {
            sm.registerListener(this, rotationVectorSensor, SensorManager.SENSOR_DELAY_GAME)
        } else if (geomagRotationSensor != null) {
            sm.registerListener(this, geomagRotationSensor, SensorManager.SENSOR_DELAY_GAME)
        } else {
            accelSensor?.let { sm.registerListener(this, it, SensorManager.SENSOR_DELAY_GAME) }
        }
    }

    private fun stopCompassListeners() {
        sensorManager?.unregisterListener(this)
    }

    override fun onSensorChanged(event: SensorEvent?) {
        val ev = event ?: return
        val sink = eventSink ?: return

        when (ev.sensor.type) {
            Sensor.TYPE_MAGNETIC_FIELD -> {
                val mx = ev.values[0]
                val my = ev.values[1]
                val mz = ev.values[2]
                lastMagneticStrengthUt = sqrt((mx * mx + my * my + mz * mz).toDouble())
                lastAccuracy = ev.accuracy

                val alpha = 0.2f
                if (!hasGeomagnetic) {
                    geomagnetic[0] = mx
                    geomagnetic[1] = my
                    geomagnetic[2] = mz
                    hasGeomagnetic = true
                } else {
                    geomagnetic[0] = alpha * mx + (1f - alpha) * geomagnetic[0]
                    geomagnetic[1] = alpha * my + (1f - alpha) * geomagnetic[1]
                    geomagnetic[2] = alpha * mz + (1f - alpha) * geomagnetic[2]
                }

                if (rotationVectorSensor == null && geomagRotationSensor == null && hasGravity) {
                    emitFromGravityAndMag(sink)
                }
            }

            Sensor.TYPE_ACCELEROMETER -> {
                val alpha = 0.2f
                if (!hasGravity) {
                    gravity[0] = ev.values[0]
                    gravity[1] = ev.values[1]
                    gravity[2] = ev.values[2]
                    hasGravity = true
                } else {
                    gravity[0] = alpha * ev.values[0] + (1f - alpha) * gravity[0]
                    gravity[1] = alpha * ev.values[1] + (1f - alpha) * gravity[1]
                    gravity[2] = alpha * ev.values[2] + (1f - alpha) * gravity[2]
                }
                if (rotationVectorSensor == null && geomagRotationSensor == null && hasGeomagnetic) {
                    emitFromGravityAndMag(sink)
                }
            }

            Sensor.TYPE_ROTATION_VECTOR, Sensor.TYPE_GEOMAGNETIC_ROTATION_VECTOR -> {
                val rotationMatrix = FloatArray(9)
                SensorManager.getRotationMatrixFromVector(rotationMatrix, ev.values)
                emitAzimuthFromMatrix(rotationMatrix, sink)
            }
        }
    }

    private fun emitFromGravityAndMag(sink: EventChannel.EventSink) {
        val r = FloatArray(9)
        val i = FloatArray(9)
        if (SensorManager.getRotationMatrix(r, i, gravity, geomagnetic)) {
            emitAzimuthFromMatrix(r, sink)
        }
    }

    private fun emitAzimuthFromMatrix(rotationMatrix: FloatArray, sink: EventChannel.EventSink) {
        val adjustedMatrix = FloatArray(9)
        @Suppress("DEPRECATION")
        val displayRotation = (getSystemService(Context.WINDOW_SERVICE) as? WindowManager)?.defaultDisplay?.rotation
            ?: Surface.ROTATION_0

        // Ekran yatay (masada düz) veya eğimli tutulsa bile ahize (cihazın üst kısmı +Y) yönünü baz al
        when (displayRotation) {
            Surface.ROTATION_90 -> SensorManager.remapCoordinateSystem(
                rotationMatrix,
                SensorManager.AXIS_Y,
                SensorManager.AXIS_MINUS_X,
                adjustedMatrix
            )
            Surface.ROTATION_180 -> SensorManager.remapCoordinateSystem(
                rotationMatrix,
                SensorManager.AXIS_MINUS_X,
                SensorManager.AXIS_MINUS_Y,
                adjustedMatrix
            )
            Surface.ROTATION_270 -> SensorManager.remapCoordinateSystem(
                rotationMatrix,
                SensorManager.AXIS_MINUS_Y,
                SensorManager.AXIS_X,
                adjustedMatrix
            )
            else -> System.arraycopy(rotationMatrix, 0, adjustedMatrix, 0, 9)
        }

        val orientation = FloatArray(3)
        SensorManager.getOrientation(adjustedMatrix, orientation)
        var azimuthDeg = Math.toDegrees(orientation[0].toDouble())
        azimuthDeg = (azimuthDeg + 360.0) % 360.0

        val pitchDeg = Math.toDegrees(orientation[1].toDouble())
        val rollDeg = Math.toDegrees(orientation[2].toDouble())

        val needCalibration = lastAccuracy == SensorManager.SENSOR_STATUS_UNRELIABLE ||
                lastAccuracy == SensorManager.SENSOR_STATUS_ACCURACY_LOW ||
                lastMagneticStrengthUt < 22.0 || lastMagneticStrengthUt > 68.0

        val payload = mapOf(
            "heading" to azimuthDeg,
            "isTrueNorth" to false,
            "magneticStrength" to lastMagneticStrengthUt,
            "needsCalibration" to needCalibration,
            "pitch" to pitchDeg,
            "roll" to rollDeg
        )
        sink.success(payload)
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        if (sensor?.type == Sensor.TYPE_MAGNETIC_FIELD || sensor?.type == Sensor.TYPE_ROTATION_VECTOR) {
            lastAccuracy = accuracy
        }
    }
}
