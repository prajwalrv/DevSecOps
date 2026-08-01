One important note: **Data Stores do not perform actions**. They only **persist data**. 
Therefore, their catalog is slightly different from the Process Catalog.

---

# Data Store Catalog Structure

We'll use this template for each data store:

| Field                 | Description                              |
| --------------------- | ---------------------------------------- |
| Data Store ID         | Unique identifier (D1, D2...)            |
| Data Store Name       | Storage component                        |
| Purpose               | Why it exists                            |
| Stored Data           | What information it contains             |
| Read By               | Which processes read from it             |
| Written By            | Which processes write to it              |
| Security Requirements | Confidentiality, Integrity, Availability |
| Trust Boundary        | Which boundary protects it               |

---

# D1 – Room Database

### Data Store ID

```text
D1
```

### Data Store Name

```text
Room Database
```

### Purpose

Stores structured application data that must persist across application restarts.

### Stored Data

* Recently Played
* Favorites
* Playlists
* Search History
* Download Metadata
* Track Metadata
* User Preferences
* Playback History

### Read By

* P1 Presentation UI
* P3 Playback Controller
* P4 Search & Metadata Manager
* P7 Download Manager

### Written By

* P3 Playback Controller
* P4 Search & Metadata Manager
* P7 Download Manager

### Security Requirements

**Confidentiality**

* Medium

**Integrity**

* High

**Availability**

* High

### Trust Boundary

```text
TB5
Persistent Storage Boundary
```

---

# D2 – ExoPlayer SimpleCache

### Data Store ID

```text
D2
```

### Data Store Name

```text
ExoPlayer SimpleCache
```

### Purpose

Caches streamed audio chunks to improve playback performance and reduce repeated network requests.

### Stored Data

* Cached audio chunks
* Buffer information
* Cache metadata

### Read By

* P6 ExoPlayer Engine

### Written By

* P6 ExoPlayer Engine

### Security Requirements

**Confidentiality**

* Medium

**Integrity**

* High

**Availability**

* High

### Trust Boundary

```text
TB5
```

---

# D3 – Download Store

### Data Store ID

```text
D3
```

### Data Store Name

```text
Download Store
```

### Purpose

Stores permanently downloaded songs and related offline assets.

### Stored Data

* Downloaded audio
* Album artwork
* Offline metadata
* Download status

### Read By

* P6 ExoPlayer Engine
* P7 Download Manager

### Written By

* P7 Download Manager

### Security Requirements

**Confidentiality**

* High

**Integrity**

* High

**Availability**

* High

### Trust Boundary

```text
TB5
```

---

# D4 – Android Keystore

### Data Store ID

```text
D4
```

### Data Store Name

```text
Android Keystore
```

### Purpose

Securely stores cryptographic keys used by the application.

### Stored Data

* AES Keys
* RSA/ECC Keys (if used)
* Encryption Keys
* Key Aliases

> **Important:** The Keystore stores **keys**, not the encrypted data itself.

### Read By

* P2 Authentication Manager

### Written By

* P2 Authentication Manager

### Security Requirements

**Confidentiality**

* Very High

**Integrity**

* Very High

**Availability**

* Medium

### Trust Boundary

```text
TB4
Secure Storage Boundary
```

---

# D5 – Encrypted Preferences

### Data Store ID

```text
D5
```

### Data Store Name

```text
Encrypted Preferences
```

*(Implementation could be EncryptedSharedPreferences or Encrypted DataStore.)*

### Purpose

Stores encrypted application configuration and authentication session information.

### Stored Data

* Firebase User ID
* Authentication Session
* User Preferences
* Feature Flags
* Configuration Values

### Read By

* P2 Authentication Manager
* P1 Presentation UI

### Written By

* P2 Authentication Manager

### Security Requirements

**Confidentiality**

* High

**Integrity**

* High

**Availability**

* Medium

### Trust Boundary

```text
TB5
```

---

# D6 – Local Logs

### Data Store ID

```text
D6
```

### Data Store Name

```text
Local Logs
```

### Purpose

Stores application logs for diagnostics, auditing, troubleshooting, and security monitoring.

### Stored Data

* Authentication Events
* Playback Events
* Download Events
* Error Logs
* Security Events
* Crash Information

### Read By

* P8 Logging Manager
* Developers (during debugging)

### Written By

* P8 Logging Manager

### Security Requirements

**Confidentiality**

* Medium

**Integrity**

* High

**Availability**

* Medium

### Trust Boundary

```text
TB5
```

---

# Complete Data Store Summary

| ID     | Data Store            | Primary Purpose           | CIA Priority          |
| ------ | --------------------- | ------------------------- | --------------------- |
| **D1** | Room Database         | User data and metadata    | **I > A > C**         |
| **D2** | SimpleCache           | Streaming audio cache     | **I > A > C**         |
| **D3** | Download Store        | Offline music storage     | **C = I = A (High)**  |
| **D4** | Android Keystore      | Cryptographic keys        | **C = I (Very High)** |
| **D5** | Encrypted Preferences | Sessions and app settings | **C = I (High)**      |
| **D6** | Local Logs            | Auditing and diagnostics  | **I > C > A**         |

---
