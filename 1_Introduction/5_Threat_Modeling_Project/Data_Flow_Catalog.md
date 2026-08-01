---

# Professional Data Flow Catalog

This accompanies the DFD and is what security architects typically produce.

| DF       | Source                       | Destination                   | Data Transferred                                                                 | Protocol                              | Trust Boundary |
| -------- | ---------------------------- | ----------------------------- | -------------------------------------------------------------------------------- | ------------------------------------- | -------------- |
| **DF1**  | EE1 User                     | P1 Presentation UI            | Phone number, OTP, search queries, playback commands, playlist actions, settings | User Input                            | **TB1**        |
| **DF2**  | P1 Presentation UI           | P2 Authentication Manager     | Phone number, OTP                                                                | Internal                              | None           |
| **DF3**  | P1 Presentation UI           | P3 Playback Controller        | Play, Pause, Next, Previous, Seek, Download                                      | Internal                              | None           |
| **DF4**  | P2 Authentication Manager    | EE3 Firebase Authentication   | Phone number, OTP verification request                                           | HTTPS/TLS                             | **TB2**        |
| **DF5**  | P3 Playback Controller       | P4 Search & Metadata Manager  | Search request, selected video ID                                                | Internal                              | None           |
| **DF6**  | P4 Search & Metadata Manager | EE4 YouTube Services          | Search request, metadata request                                                 | HTTPS/TLS                             | **TB2**        |
| **DF7**  | EE4 YouTube Services         | P5 Stream Manifest Extractor  | Metadata, stream manifest                                                        | HTTPS/TLS                             | **TB2**        |
| **DF8**  | P5 Stream Manifest Extractor | P6 ExoPlayer Engine           | Audio stream URL (signed URL)                                                    | Internal                              | None           |
| **DF9**  | P6 ExoPlayer Engine          | EE4 YouTube CDN               | Audio stream request                                                             | HTTPS/TLS                             | **TB2**        |
| **DF10** | P6 ExoPlayer Engine          | D2 SimpleCache                | Audio chunks for streaming cache                                                 | Internal                              | **TB5**        |
| **DF11** | P6 ExoPlayer Engine          | EE2 Android OS                | Audio output, MediaSession updates, notification requests                        | Android IPC/API                       | **TB3**        |
| **DF12** | EE2 Android OS               | EE5 External Playback Devices | Audio stream, media controls                                                     | Bluetooth / Cast / Android Auto APIs  | **TB6**        |
| **DF13** | P4 Search & Metadata Manager | D1 Room Database              | History, playlists, favorites, metadata, search history                          | SQLite                                | **TB5**        |
| **DF14** | P7 Download Manager          | D3 Download Store             | Downloaded audio files                                                           | File I/O                              | **TB5**        |
| **DF15** | P7 Download Manager          | D1 Room Database              | Download metadata, offline status                                                | SQLite                                | **TB5**        |
| **DF16** | P2 Authentication Manager    | D4 Android Keystore           | Generate/retrieve encryption keys                                                | Android Keystore API                  | **TB4**        |
| **DF17** | P2 Authentication Manager    | D5 Encrypted Preferences      | Encrypted session, Firebase user ID, preferences                                 | Encrypted SharedPreferences/DataStore | **TB5**        |
| **DF18** | P8 Logging Manager           | D6 Local Logs                 | Security logs, playback logs, audit logs                                         | File I/O / SQLite                     | **TB5**        |

---

# Why this is important

When we start STRIDE, we won't analyze the whole app at once.

We'll go one element at a time.

For example:

### Process

```
P2 Authentication Manager
```

We'll ask:

* Spoofing?
* Tampering?
* Repudiation?
* Information Disclosure?
* Denial of Service?
* Elevation of Privilege?

---

### Data Store

```
D4 Android Keystore
```

We'll ask the same STRIDE questions.

---

### Data Flow

```
DF9
ExoPlayer → YouTube CDN
```

We'll ask:

* Can this connection be spoofed?
* Can it be tampered with?
* Can data be disclosed?
* Can it be interrupted (DoS)?

---

# This is exactly how Threat Dragon works

OWASP Threat Dragon doesn't just analyze boxes. It analyzes:

* External Entities
* Processes
* Data Stores
* **Data Flows**

Each **DF** becomes its own analysis target.

---
