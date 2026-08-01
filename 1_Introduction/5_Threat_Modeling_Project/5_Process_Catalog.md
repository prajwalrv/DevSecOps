This is the **most important catalog** in the entire threat model.

Why?

Because **STRIDE is primarily applied to Processes**. A process is where data is received, validated, transformed, and sent elsewhere. Most security vulnerabilities originate in processes.

---

# Process Catalog Structure

We'll use the following template for every process:

| Field                     | Description                     |
| ------------------------- | ------------------------------- |
| Process ID                | Unique identifier (P1, P2...)   |
| Process Name              | Logical business process        |
| Purpose                   | Why the process exists          |
| Responsibilities          | What it does                    |
| Inputs                    | Data it receives                |
| Outputs                   | Data it sends                   |
| Connected Components      | Processes, EE, DS               |
| Security Responsibilities | What it must protect            |
| Trust Boundary            | Which trust boundary it crosses |

---

# P1 – Presentation UI

### Process ID

```text
P1
```

### Process Name

```text
Presentation UI
```

### Purpose

Provides the primary user interface for interacting with the application.

### Responsibilities

* Display Home screen
* Display Search
* Display Library
* Display Downloads
* Display Settings
* Display Login
* Display Now Playing
* Accept user interactions
* Show playback status
* Display errors

### Inputs

* User input
* Search results
* Authentication status
* Playback state
* Playlist data
* Download status

### Outputs

* Login request
* Search request
* Playback commands
* Download requests
* Playlist modifications

### Connected Components

```text
EE1 User

P2 Authentication Manager

P3 Playback Controller
```

### Security Responsibilities

* Validate user input
* Prevent UI injection
* Prevent unauthorized navigation
* Display only authorized information

### Trust Boundary

```text
TB1
```

---

# P2 – Authentication Manager

### Process ID

```text
P2
```

### Purpose

Manages user authentication using Firebase Authentication.

### Responsibilities

* Request OTP
* Verify OTP
* Create session
* Refresh session
* Logout
* Store authentication state

### Inputs

* Phone number
* OTP
* Firebase responses

### Outputs

* Login result
* Authentication status
* Session information

### Connected Components

```text
P1 Presentation UI

EE3 Firebase Authentication

D4 Android Keystore

D5 Encrypted Preferences
```

### Security Responsibilities

* Validate OTP
* Protect authentication tokens
* Encrypt session data
* Prevent session hijacking
* Secure logout

### Trust Boundary

```text
TB2

TB4

TB5
```

---

# P3 – Playback Controller

### Process ID

```text
P3
```

### Purpose

Coordinates all playback-related activities within the application.

### Responsibilities

* Manage playback queue
* Play/Pause
* Skip tracks
* Repeat
* Shuffle
* Coordinate playback lifecycle
* Handle playback errors
* Coordinate download requests

### Inputs

* Playback commands
* Selected song
* Queue updates

### Outputs

* Playback requests
* Search requests
* Download requests
* Playback state updates

### Connected Components

```text
P1 Presentation UI

P4 Search & Metadata Manager

P6 ExoPlayer

P7 Download Manager
```

### Security Responsibilities

* Authorize playback actions
* Validate playback requests
* Prevent malformed requests

### Trust Boundary

```text
Internal
```

---

# P4 – Search & Metadata Manager

### Process ID

```text
P4
```

### Purpose

Searches YouTube and retrieves metadata for music content.

### Responsibilities

* Search songs
* Search albums
* Search artists
* Retrieve metadata
* Parse metadata
* Cache metadata

### Inputs

* Search query
* Video ID

### Outputs

* Search results
* Metadata
* Stream request

### Connected Components

```text
P3 Playback Controller

EE4 YouTube Services

P5 Stream Manifest Extractor

D1 Room Database
```

### Security Responsibilities

* Validate server responses
* Handle malformed metadata
* Prevent injection through metadata
* Protect search history

### Trust Boundary

```text
TB2

TB5
```

---

# P5 – Stream Manifest Extractor

### Process ID

```text
P5
```

### Purpose

Obtains the audio-only stream URL from YouTube metadata.

### Responsibilities

* Request stream manifest
* Parse manifest
* Select highest-quality audio stream
* Return signed audio URL

### Inputs

* Video ID
* Stream manifest

### Outputs

* Audio stream URL

### Connected Components

```text
P4 Search Manager

EE4 YouTube Services

P6 ExoPlayer
```

### Security Responsibilities

* Validate manifest
* Ignore malformed streams
* Reject invalid URLs
* Protect signed URLs

### Trust Boundary

```text
TB2
```

---

# P6 – ExoPlayer Engine

### Process ID

```text
P6
```

### Purpose

Streams, decodes, and plays audio.

### Responsibilities

* Stream audio
* Decode audio
* Buffer audio
* Handle interruptions
* Maintain playback state
* Update MediaSession

### Inputs

* Audio URL

### Outputs

* Audio output
* Cache writes
* MediaSession updates

### Connected Components

```text
P5 Stream Manifest Extractor

D2 SimpleCache

EE2 Android OS

EE5 External Playback Devices
```

### Security Responsibilities

* Secure streaming
* Validate media URLs
* Prevent playback abuse
* Protect cached content

### Trust Boundary

```text
TB2

TB3

TB5

TB6
```

---

# P7 – Download Manager

### Process ID

```text
P7
```

### Purpose

Manages offline downloads and downloaded content.

### Responsibilities

* Download songs
* Pause downloads
* Resume downloads
* Delete downloads
* Verify downloaded files

### Inputs

* Download request

### Outputs

* Downloaded files
* Download status

### Connected Components

```text
P3 Playback Controller

D3 Download Store

D1 Room Database
```

### Security Responsibilities

* Verify downloaded content
* Prevent file corruption
* Protect downloaded media
* Manage storage safely

### Trust Boundary

```text
TB5
```

---

# P8 – Logging Manager

### Process ID

```text
P8
```

### Purpose

Records application events for diagnostics, auditing, and security monitoring.

### Responsibilities

* Log authentication events
* Log playback events
* Log downloads
* Log errors
* Log security events

### Inputs

* Events from all application processes

### Outputs

* Structured log records

### Connected Components

```text
All Processes

D6 Local Logs
```

### Security Responsibilities

* Prevent sensitive data from being logged
* Protect log integrity
* Prevent log tampering
* Support auditing

### Trust Boundary

```text
TB5

```
---
