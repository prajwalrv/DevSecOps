## A DFD only has four object types.

```text
  | DFD Element     | Meaning                       |
  | --------------- | ----------------------------- |
  | External Entity | Something outside your system |
  | Process         | Performs work                 |
  | Data Store      | Stores data                   |
  | Data Flow       | Information moving            |

```
## Instead of P1 Android Music App : Decompose P1
## Decompose P1 : Our application can be divided into the following processes.
```text
P1  Presentation UI
P2  Authentication Manager
P3  Playback Controller
P4  Search & Metadata Manager
P5  Stream Manifest Extractor
P6  ExoPlayer Engine
P7  Download Manager
P8  Logging Manager
```
## Identify Data Stores : DFDs show every storage separately.
```text
D1 Room Database
D2 SimpleCache
D3 Download Store
D4 Android Keystore
D5 Encrypted Preferences
D6 Local Logs
```
## D1 Room Database
```text
History
Favorites
Playlists
Recently Played
Metadata
Search History
Settings
```
## D2 SimpleCache
```text
Temporary Audio Chunks
```
## D3 Download Store
```text
Downloaded Songs
Album Art
Offline Metadata
```
## D4 Android Keystore
```text
AES Keys
Token Encryption Keys
Signing Keys

----> Only cryptographic keys.
```
## D5 Encrypted Preferences
```text
Firebase Session
User ID
App Preferences
Feature Flags
```
## D6 Local Logs
```text
Playback Logs
Authentication Logs
Crash Logs
Application Events
```

## External Entities
```text
EE1 User
EE2 Android OS
EE3 Firebase Authentication
EE4 YouTube Services
EE5 External Playback Devices
```
## DFD Diagram
```text
                                                LEVEL-1 DATA FLOW DIAGRAM
                                   Custom Audio-Only YouTube Music Client


┌───────────────────────────────┐
│         EE1 - User            │
│-------------------------------│
│ Search                        │
│ Login                         │
│ Play / Pause                  │
│ Download                      │
│ Playlist Management           │
└──────────────┬────────────────┘
               │
               │ DF1
               ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│ P1 - Presentation UI                                                                        │
│---------------------------------------------------------------------------------------------│
│ Home │ Search │ Library │ Downloads │ Settings │ Login │ Now Playing │ Mini Player          │
└──────────────┬───────────────────────────────────────────────┬──────────────────────────────┘
               │                                               │
        DF2    │                                               │ DF3
               ▼                                               ▼
┌───────────────────────────────┐                 ┌────────────────────────────────┐
│ P2 Authentication Manager     │                 │ P3 Playback Controller         │
└──────────────┬────────────────┘                 └──────────────┬─────────────────┘
               │                                                 │
        DF4    │                                                 │ DF5
               ▼                                                 ▼
┌───────────────────────────────┐                 ┌────────────────────────────────┐
│ EE3 Firebase Authentication   │                 │ P4 Search & Metadata Manager   │
└───────────────────────────────┘                 └──────────────┬─────────────────┘
                                                                  │
                                                          DF6     │
                                                                  ▼
                                                      ┌────────────────────────────┐
                                                      │ EE4 YouTube Services       │
                                                      │ Search / Metadata API      │
                                                      └─────────────▲──────────────┘
                                                                    │
                                                            DF7     │
                                                                    ▼
                                              ┌──────────────────────────────────┐
                                              │ P5 Stream Manifest Extractor     │
                                              └──────────────┬───────────────────┘
                                                             │
                                                      DF8    │ Audio Stream URL
                                                             ▼
                                              ┌──────────────────────────────────┐
                                              │ P6 ExoPlayer Engine              │
                                              └───────┬───────────────┬──────────┘
                                                      │               │
                                                 DF9  │               │ DF10
                                        Stream Audio  │               ▼
                                                      │       ┌────────────────────┐
                                                      ▼       │ D2 SimpleCache     │
                                            ┌────────────────┐│ Streaming Cache    │
                                            │ EE4 YouTube    │└────────────────────┘
                                            │ CDN            │
                                            └────────────────┘
                                                      │
                                                      │ DF11
                                                      ▼
                                            ┌────────────────────┐
                                            │ EE2 Android OS     │
                                            │ Audio Framework    │
                                            └─────────┬──────────┘
                                                      │
                                                      │ DF12
                                                      ▼
                                         ┌────────────────────────────┐
                                         │ EE5 External Playback      │
                                         │ Bluetooth / Auto / Wear    │
                                         │ Chromecast / Assistant     │
                                         └────────────────────────────┘



────────────────────────────────────────────────────────────────────────────────────────────────


                    STORAGE & SECURITY COMPONENTS


                     ┌────────────────────────────┐
                     │ D1 Room Database           │
                     │----------------------------│
                     │ History                    │
                     │ Favorites                  │
                     │ Playlists                  │
                     │ Metadata                   │
                     │ Search History             │
                     │ Recently Played            │
                     │ Settings                   │
                     └────────────▲───────────────┘
                                  │
                           DF13   │
                                  │
                  ┌───────────────┴────────────────┐
                  │ P4 Search & Metadata Manager   │
                  └────────────────────────────────┘


                     ┌────────────────────────────┐
                     │ D3 Download Store          │
                     │----------------------------│
                     │ Offline Audio              │
                     │ Album Art                  │
                     │ Metadata                   │
                     └────────────▲───────────────┘
                                  │
                           DF14   │
                                  │
                     ┌────────────┴───────────────┐
                     │ P7 Download Manager        │
                     └────────────┬───────────────┘
                                  │
                           DF15   │
                                  ▼
                         ┌───────────────────────┐
                         │ D1 Room Database      │
                         └───────────────────────┘



                     ┌────────────────────────────┐
                     │ D4 Android Keystore        │
                     │----------------------------│
                     │ AES Keys                   │
                     │ Crypto Keys                │
                     └────────────▲───────────────┘
                                  │
                           DF16   │
                                  │
                     ┌────────────┴───────────────┐
                     │ P2 Authentication Manager  │
                     └────────────┬───────────────┘
                                  │
                           DF17   │
                                  ▼
                     ┌────────────────────────────┐
                     │ D5 Encrypted Preferences   │
                     │----------------------------│
                     │ Firebase Session           │
                     │ User ID                    │
                     │ Preferences                │
                     └────────────────────────────┘



                     ┌────────────────────────────┐
                     │ D6 Local Logs              │
                     └────────────▲───────────────┘
                                  │
                           DF18   │
                                  │
                     ┌────────────┴───────────────┐
                     │ P8 Logging Manager         │
                     └────────────────────────────┘
```
## Trust Boundaries (to draw in OWASP Threat Dragon)
```text
TB1 Android Application Boundary 
────────────────────────────────────────────
Processes : Processes like P1, P2, P3....
------------------------
P1 Presentation UI, .....


TB2  Internet Boundary
────────────────────────────────────────────
Android Music App : Crossed whenever network traffic leaves or enters the app.
------------------------
Firebase Authentication
YouTube Services
YouTube CDN


TB3  Android Platform Boundary
────────────────────────────────────────────
Android Music App : app depends on Android for media, permissions, storage APIs, and notifications.
------------------------
Android OS
Android Keystore


TB4  Secure Storage Boundary
────────────────────────────────────────────
Application Processes
------------------------
Android Keystore : Keystore has stronger protection than normal app storage.
Encrypted Preferences : Firebase ID Token (encrypted), Firebase UID, Session state, User preferences


TB5  Persistent Storage Boundary
────────────────────────────────────────────
Application Processes
------------------------
Room Database
SimpleCache
Download Store
Local Logs


TB6  External Device Boundary : Crossing this boundary means data is written to or read from persistent storage.
────────────────────────────────────────────
Android Music App
------------------------
Bluetooth
Android Auto
Wear OS
Chromecast
Google Assistant
```
