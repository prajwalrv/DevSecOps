---

# Phase 1 — Authentication Feature

Let's model only the login flow first.

## Before opening Threat Dragon, understand the real flow

Imagine you install the app for the first time.

What happens?

```text
User opens app
        │
        ▼
Presentation UI shows Login Screen
        │
        ▼
User enters Phone Number
        │
        ▼
Authentication Manager
        │
        ▼
Firebase Authentication
        │
        ▼
OTP Sent
        │
        ▼
User enters OTP
        │
        ▼
Authentication Manager
        │
        ▼
Firebase verifies OTP
        │
        ▼
Authentication Success
        │
        ▼
Android Keystore
        │
        ▼
Encrypted Preferences
        │
        ▼
Presentation UI
        │
        ▼
Home Screen
```

Notice something?

This is **already a DFD**.

---

# Now convert it into DFD components

## External Entities

```
EE1 User

EE3 Firebase Authentication
```

---

## Processes

```
P1 Presentation UI

P2 Authentication Manager
```

---

## Data Stores

```
D4 Android Keystore

D5 Encrypted Preferences
```

---

## Data Flows

We only need the authentication flows for now.

| DF  | From | To  | Data                                      |
| --- | ---- | --- | ----------------------------------------- |
| DF1 | EE1  | P1  | Phone Number, OTP                         |
| DF2 | P1   | P2  | Login Request                             |
| DF3 | P2   | EE3 | OTP Verification Request                  |
| DF4 | EE3  | P2  | Authentication Result + Firebase ID Token |
| DF5 | P2   | D4  | Generate / Retrieve Encryption Key        |
| DF6 | P2   | D5  | Store Encrypted Session                   |
| DF7 | P2   | P1  | Authentication Success                    |

---

# Canvas Layout

This is exactly how I would place it.

```text
                 TB2 Internet Boundary

        +------------------------------------+
        | EE3 Firebase Authentication        |
        +------------------------------------+



+--------------------------------------------------------------------+
|               TB1 Android Application Boundary                     |
|                                                                    |
|   +-----------+        +--------------------------+                |
|   | P1 UI     |------->| P2 Authentication        |                |
|   +-----------+        +--------------------------+                |
|                                                                    |
+--------------------------------------------------------------------+

        +---------------------+     +-----------------------+
        | TB4 Secure Storage  |     | TB5 Persistent Storage|
        | D4 Android Keystore |     | D5 Encrypted Prefs    |
        +---------------------+     +-----------------------+



EE1 User
```

Notice something important:

👉 **The User stays outside every trust boundary.**

That is correct.

---
