---

# 1. External Entity Catalog (EE1–EE5)

External Entities are systems, people, or devices **outside the trust boundary of your application** that exchange data with it.

| ID      | External Entity               | Description                                                                                                                                                                                  | Data Exchanged                                                                                                | Why is it External?                                                                                                 |
| ------- | ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| **EE1** | **User**                      | The person using the Android music application. Initiates all actions such as login, search, playback, downloads, and playlist management.                                                   | Phone number, OTP, search queries, playback commands, playlist actions, settings, UI responses                | The user is outside the application's control and all input must be treated as untrusted.                           |
| **EE2** | **Android Operating System**  | Provides platform services required by the application, including permissions, MediaSession, notifications, audio focus, Bluetooth APIs, storage APIs, wake locks, and lifecycle management. | Permission results, audio focus events, media controls, notification events, storage access, system callbacks | The Android OS is a separate trusted platform that the application depends on but does not control.                 |
| **EE3** | **Firebase Authentication**   | Third-party authentication provider responsible for phone number verification, OTP generation, OTP validation, identity verification, and secure authentication token issuance.              | Phone number, OTP verification requests, authentication responses, ID tokens                                  | Authentication is performed by Firebase servers outside the application boundary.                                   |
| **EE4** | **YouTube Services**          | External cloud service that provides search results, video metadata, stream manifests, and audio content required for playback.                                                              | Search requests, metadata requests, stream manifest requests, audio stream requests and responses             | YouTube infrastructure is external to the application and communicates over the public Internet.                    |
| **EE5** | **External Playback Devices** | Devices and ecosystems that interact with the application for media playback, including Bluetooth headsets, Android Auto, Wear OS, Chromecast, and Google Assistant.                         | Playback controls, media metadata, audio output, voice commands                                               | These devices communicate with the application through Android but remain outside the application's trust boundary. |

---

## Visual Mapping

```text
EE1  User

EE2  Android Operating System

EE3  Firebase Authentication

EE4  YouTube Services

EE5  External Playback Devices
```

---

# Why only five?

Many beginners ask:

> "Should DNS be an External Entity?"

Technically yes.

Should TLS?

No.

Should Wi-Fi Router?

Maybe.

Should Internet?

Maybe.

For a **Level-1 DFD**, these are implementation details rather than business entities.

Keeping the model at five external entities strikes a good balance between clarity and completeness. If later you decide to perform a deeper infrastructure-level threat model, you can introduce additional entities such as DNS, NTP, or the network gateway.

---
