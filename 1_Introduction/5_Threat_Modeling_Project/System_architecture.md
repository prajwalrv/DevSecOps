## Android Music Player Application System Architecture

```text
                                           ┌──────────────────────────────┐
                                           │         EXTERNAL             │
                                           │      YouTube Services        │
                                           │ (Search, Metadata, Streams)  │
                                           └──────────────┬───────────────┘
                                                          │
                                             HTTPS (TLS)  │
                                                          ▼
┌───────────────────────────────────────────────────────────────────────────────────────────────┐
│                                 ANDROID MUSIC APPLICATION                                     │
│                                                                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │                         PRESENTATION LAYER                                              │  │
│  │-----------------------------------------------------------------------------------------│  │
│  │ Login │ Home │ Search │ Library │ Downloads │ Settings │ Now Playing │ Mini Player      │  │
│  └──────────────────────────────────────────┬──────────────────────────────────────────────┘  │
│                                             │                                                 │
│                                             ▼                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │                    APPLICATION / DOMAIN LAYER                                           │  │
│  │-----------------------------------------------------------------------------------------│  │
│  │ ViewModels                                                                              │  │
│  │ Playback Controller                                                                     │  │
│  │ Authentication Manager                                                                  │  │
│  │ Playlist Manager                                                                        │  │
│  │ Download Manager                                                                        │  │
│  │ Logging Manager                                                                         │  │
│  └──────────────────────────────────────────┬──────────────────────────────────────────────┘  │
│                                             │                                                 │
│                                             ▼                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │                     NETWORK & EXTRACTION LAYER                                          │  │
│  │-----------------------------------------------------------------------------------------│  │
│  │ HTTPS Client                                                                            │  │
│  │ YouTube Client                                                                          │  │
│  │ OTP Client                                                                              │  │
│  │ Stream Manifest Extractor                                                               │  │
│  │ Metadata Parser                                                                         │  │
│  └──────────────────────────────────────────┬──────────────────────────────────────────────┘  │
│                                             │                                                 │
│                                             ▼                                                 │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────┐  │
│  │                        PLAYBACK ENGINE                                                  │  │
│  │-----------------------------------------------------------------------------------------│  │
│  │ Foreground MediaService                                                                 │  │
│  │ MediaSession                                                                            │  │
│  │ ExoPlayer                                                                               │  │
│  │ Audio Focus Manager                                                                     │  │
│  │ Notification Controller                                                                 │  │
│  └──────────────┬──────────────────────────────┬───────────────────────────────────────────┘  │
│                 │                              │                                              │
│                 ▼                              ▼                                              │
│  ┌────────────────────────┐      ┌────────────────────────────────────────────────────────┐   │
│  │   SimpleCache          │      │            LOCAL DATA & SECURITY                       │   │
│  │ (Streaming Cache)      │      │--------------------------------------------------------│   │
│  └────────────────────────┘      │ Room Database                                          │   │
│                                  │ Download Store                                         │   │
│                                  │ Android Keystore                                       │   │
│                                  │ Encrypted Preferences                                  │   │
│                                  │ Local Logs                                             │   │
│                                  └────────────────────────────────────────────────────────┘   │
└───────────────────────────────────────────────────────────────────────────────────────────────┘

          ▲
          │
     User (Single Device Owner)

          │
          ▼
┌───────────────────────────────────────────────────────────────────────────────────────────────┐
│                              ANDROID OPERATING SYSTEM                                         │
│-----------------------------------------------------------------------------------------------│
│ Runtime │ Permissions │ Audio Focus │ Notifications │ Wake Locks │ Bluetooth │ Android Auto   │
│ Wear OS │ Chromecast │ Google Assistant │ Media Framework │ Network Stack │ File System       │
└───────────────────────────────────────────────────────────────────────────────────────────────┘
```

## App Process Flow diagram 
```text
                                             Internet
                                                 │
                                                 ▼
                                         Streaming Server
                                                 │
                                                 ▼
                                      Stream Extractor Module
                                                 │
                                                 ▼
                                           ExoPlayer Engine
                                                 │
                                        ┌────────┴────────┐
                                        ▼                 ▼
                                  SimpleCache         Room DB
                                        ▲
                                        │
                                  MediaService
                                        ▲
                                        │
                                   ViewModels
                                        ▲
                                        │
                                Jetpack Compose UI
                                        ▲
                                        │
                                      User
```
## Functional Modules 

```text
                ┌────────────────────────────────────────────────────────────────────────────┐
                │                        EXTERNAL ENTITIES                                   │
                ├────────────────────────────────────────────────────────────────────────────┤
                │ EE1 User                                                                   │
                │ EE2 Android OS                                                             │
                │ EE3 YouTube Services                                                       │
                │ EE4 SMS / OTP Provider                                                     │
                │ EE5 Bluetooth Devices                                                      │
                │ EE6 Android Auto                                                           │
                │ EE7 Wear OS                                                                │
                │ EE8 Chromecast                                                             │
                │ EE9 Google Assistant / Voice Search                                        │
                └────────────────────────────────────────────────────────────────────────────┘
                
                
                                               ▼
                
                ┌────────────────────────────────────────────────────────────────────────────┐
                │                     PRESENTATION LAYER                                     │
                ├────────────────────────────────────────────────────────────────────────────┤
                │ Home                                                                       │
                │ Search                                                                     │
                │ Library                                                                    │
                │ Now Playing                                                                │
                │ Settings                                                                   │
                │ Login                                                                       │
                └────────────────────────────────────────────────────────────────────────────┘
                
                                               ▼
                
                ┌────────────────────────────────────────────────────────────────────────────┐
                │                   APPLICATION / DOMAIN LAYER                               │
                ├────────────────────────────────────────────────────────────────────────────┤
                │ Playback ViewModel                                                         │
                │ Search ViewModel                                                           │
                │ Library ViewModel                                                          │
                │ Authentication Manager                                                     │
                │ Download Manager                                                           │
                │ Playlist Manager                                                           │
                │ Settings Manager                                                           │
                │ Logging Manager                                                            │
                └────────────────────────────────────────────────────────────────────────────┘
                
                                               ▼
                
                ┌────────────────────────────────────────────────────────────────────────────┐
                │                    NETWORK & EXTRACTION LAYER                              │
                ├────────────────────────────────────────────────────────────────────────────┤
                │ HTTPS Client                                                               │
                │ OTP Client                                                                 │
                │ YouTube API Client                                                         │
                │ Stream Manifest Extractor                                                  │
                │ Metadata Parser                                                            │
                └────────────────────────────────────────────────────────────────────────────┘
                
                                               ▼
                
                ┌────────────────────────────────────────────────────────────────────────────┐
                │                    PLAYBACK ENGINE                                         │
                ├────────────────────────────────────────────────────────────────────────────┤
                │ Foreground MediaService                                                    │
                │ MediaSession                                                               │
                │ ExoPlayer                                                                  │
                │ Audio Focus Manager                                                        │
                │ Notification Controller                                                    │
                └────────────────────────────────────────────────────────────────────────────┘
                
                                               ▼
                
                ┌────────────────────────────────────────────────────────────────────────────┐
                │                  LOCAL STORAGE & SECURITY                                  │
                ├────────────────────────────────────────────────────────────────────────────┤
                │ Room Database                                                              │
                │ SimpleCache                                                                │
                │ Download Store                                                             │
                │ Android Keystore                                                           │
                │ Encrypted Preferences                                                      │
                │ Local Logs                                                                 │
                └────────────────────────────────────────────────────────────────────────────┘
```

## Application Sample usage flow :

```text
                User
                 │
                 ▼
                Search UI
                 │
                 ▼
                Search ViewModel
                 │
                 ▼
                YouTube Client
                 │
                 ▼
                YouTube Search
                 │
                 ▼
                Search Results
                 │
                 ▼
                Search UI
                
                ──────── User taps Play ────────
                
                User
                 │
                 ▼
                Playback Controller
                 │
                 ▼
                Stream Manifest Extractor
                 │
                 ▼
                YouTube
                 │
                 ▼
                Audio Stream URL
                 │
                 ▼
                Playback Controller
                │
                ├────────► Stream Manifest Extractor
                │                 │
                │                 ▼
                │            YouTube (get metadata + audio URL)
                │
                └────────► ExoPlayer
                                 │
                                 ├────────► YouTube CDN (downloads audio chunks)
                                 │
                                 ├────────► SimpleCache (stores chunks)
                                 │
                                 ├────────► Room DB (history, metadata)
                                 │
                                 ├────────► MediaSession
                                 │
                                 ├────────► Notification
                                 │
                                 └────────► Speaker 🎵
 ```
