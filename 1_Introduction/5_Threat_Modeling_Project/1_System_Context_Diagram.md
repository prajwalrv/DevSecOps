## The first DFD is called the Context Diagram.

```text
  For the Context Diagram you need:
  ✅ External Entities
  ✅ One Process
  ✅ Data Flows
  ✅ Trust Boundaries
```
## Context Diagram
```text
                    ┌─────────────────────┐
                    │      EE1 User       │
                    └──────────┬──────────┘
                               │ DF1 / DF2
                               │
                ┌──────────────▼──────────────┐
                │                             │
                │   P1 Android Music App      │
                │                             │
                └─────┬─────────┬────────┬────┘
                      │         │        │
              DF3/DF4 │         │ DF7/8  │ DF9/10
                      │         │        │
          ┌───────────▼──┐  ┌──▼──────┐ ┌───────────────┐
          │ EE3 Firebase │  │ EE2     │ │ EE5 External  │
          │ Authentication│ │ Android │ │ Playback Dev. │
          └───────────┬──┘  │   OS    │ └───────────────┘
                      │     └─────────┘
               DF5/DF6│
                      │
             ┌────────▼────────┐
             │ EE4 YouTube     │
             │    Services     │
             └─────────────────┘
```

## External Entities EE:

```text 
  EE1 - User -> Login, Search, Play, Pause, Download, Create playlists.
  EE2 – Android Operating System -> Permissions, Audio Focus, Notifications, MediaSession support, Wake Locks, File System, Bluetooth APIs.
  EE3 – Firebase Authentication -> Phone number verification, OTP delivery, OTP validation, Identity verification, Authentication token generation.
  EE4 – YouTube Services -> Search, Metadata, Stream Manifest, Audio CDN.
  EE5 – External Playback Devices -> Bluetooth, Android Auto, Wear OS, Chromecast.
```

## Define the single process P1:

```text
P1 - Android Music Application

```

## Identify Data Flows DF: Every arrow must represent actual data

## DF1 -
```text
   User
     │
     ▼
Android Music App

  Data:
  -> Phone number
  -> OTP
  -> Search queries
  -> Play/Pause
  -> Playlist changes
  -> Download requests
  -> Settings
```
## DF2 -
```text
Android Music App
        │
        ▼
       User

  Data:
  -> Search results
  -> Music playback
  -> Notifications
  -> Error messages
  -> Playlist changes
  -> Login status
  -> Playlist view
```
## DF3 -
```text
Android Music App
        │
        ▼
Firebase Authentication

  Data:
  -> Phone number
  -> OTP verification request
```
## DF4 -
```text
Firebase Authentication
        │
        ▼
Android Music App

  Data:
  -> Authentication result
  -> ID token
  -> User identifier
  -> Session status
```
## DF5 -
```text
Android Music App
        │
        ▼
YouTube Services

  Data:
  -> Search requests
  -> Metadata requests
  -> Stream manifest requests
  -> Audio stream requests
```
## DF6 -
```text
YouTube Services
        │
        ▼
Android Music App

  Data:
  -> Search results
  -> Metadata
  -> Audio manifest
  -> Audio stream
```
## DF7 -
```text
Android Music App
        │
        ▼
Android OS

  Data:
  -> Notification requests
  -> Audio Focus requests
  -> Wake Lock requests
  -> Storage access
  -> Bluetooth requests
```
## DF8 -
```text
Android OS
        │
        ▼
Android Music App

  Data:
  -> Permission results
  -> Audio Focus events
  -> Phone call interruptions
  -> Media button events
  -> Bluetooth state
  -> System callbacks
```
## DF9 -
```text
Android Music App
        │
        ▼
External Playback Devices

  Data:
  -> Audio stream
  -> Playback controls
  -> Metadata
```
## DF10 -
```text
External Playback Devices
        │
        ▼
Android Music App

  Data:
  -> Play
  -> Pause
  -> Next
  -> Previous
  -> Volume
  -> Voice commands
```

## Trust Boundaries: These are the "security fences" where trust changes.

## TB1 – User ↔ Application
```text
The user is outside the application. Any input (search text, OTP, playlist names)
is untrusted until validated.
```
## TB2 – Internet Boundary
```text
Crossed whenever the app communicates with:
  1. Firebase Authentication
  2. YouTube Services
Everything coming back over the network must be treated as untrusted until verified.
```
## TB3 – Android Sandbox Boundary
```text
Separates your application from the Android OS. 
The app relies on Android for permissions, storage, media APIs, and system services.
```
## TB4 – External Device Boundary
```text
Crossed when interacting with Bluetooth devices, Android Auto, Wear OS, or Chromecast.
```
