// package com.ezmoney.app

// import android.app.Service
// import android.content.Intent
// import android.os.IBinder
// import androidx.core.app.NotificationCompat

// class VoiceBackgroundService : Service() {

//     override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
//         val notification = NotificationCompat.Builder(this, "voice_assistant_channel")
//             .setContentTitle("EZMoney Voice Assistant")
//             .setContentText("Listening for 'Hey Fin'...")
//             .setSmallIcon(android.R.drawable.ic_btn_speak_now)
//             .setPriority(NotificationCompat.PRIORITY_LOW)
//             .build()

//         startForeground(1, notification)

//         return START_STICKY
//     }

//     override fun onBind(intent: Intent?): IBinder? = null

//     override fun onDestroy() {
//         super.onDestroy()
//         stopForeground(true)
//     }
// }