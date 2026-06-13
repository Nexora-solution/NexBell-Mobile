# NexBell Web Services Endpoint Map for Flutter Integration

Use this document as a backend contract prompt for implementing a Flutter mobile frontend against the NexBell Maven Web Services solution.

Security note: the project has a JWT filter that can populate the Spring Security context when an `Authorization: Bearer <token>` header is sent, but the active `WebSecurityConfig` permits all HTTP requests through `anyRequest().permitAll()`. Because no endpoint currently requires authorization, this map intentionally does not include an authorization-required field per endpoint.

Common conventions:
- Base URL is environment-specific. Append the paths below to the configured API host.
- JSON request bodies use `application/json`.
- Java `LocalDateTime` values should be sent as ISO-like date-time strings, for example `2026-06-12T19:30:00`.
- Known enum values: `RoleName`: `RESIDENT`, `DOORMAN`; `AccessDecision`: `APPROVED`, `REJECTED`; `CommandType`: `UNLOCK`, `LOCK`, `TOGGLE_MEDIA`.

## Bounded Context: IAM

Folder: `iam`

Purpose: user registration, login, token refresh, session logout, and password recovery/change flows.

| Method | Path | Request | Response | Mobile use |
| --- | --- | --- | --- | --- |
| POST | `/api/iam/register` | Body: `{ "email": "user@nexora.com", "password": "password123", "role": "RESIDENT" }` | `201 Created` with text `"User registered successfully"`; `400` on failure. | Create a user account for a resident or doorman. |
| POST | `/api/iam/login` | Body: `{ "email": "user@nexora.com", "password": "password123" }` | `200 OK` with `{ "id": 1, "email": "...", "accessToken": "...", "refreshToken": "..." }`; `401` if invalid. | Authenticate the user and store session tokens in Flutter secure storage. |
| POST | `/api/iam/refresh` | Body: `{ "refreshToken": "..." }` | `200 OK` with `{ "id": 1, "email": "...", "accessToken": "...", "refreshToken": "..." }`; `401` if invalid. | Rotate or renew the mobile session. |
| POST | `/api/iam/logout` | Query param: `refreshToken=<token>` | `200 OK` with text `"Session closed successfully"`. | End the current session and clear local tokens. |
| POST | `/api/iam/password/request-reset` | Body: `{ "email": "user@nexora.com" }` | `200 OK` with reset token text. | Start password recovery. In this backend, the token is returned directly. |
| POST | `/api/iam/password/confirm-reset` | Body: `{ "token": "...", "newPassword": "newPassword123" }` | `200 OK` with text `"Password reset successfully"`; `400` on failure. | Complete password recovery using a reset token. |
| PUT | `/api/iam/password/change` | Body: `{ "email": "user@nexora.com", "oldPassword": "oldPassword123", "newPassword": "newPassword123" }` | `200 OK` with text `"Password changed successfully"`. | Let a logged-in profile change its password. |

## Bounded Context: Directory

Folder: `directory`

Purpose: building, apartment, and resident directory setup and lookup.

| Method | Path | Request | Response | Mobile use |
| --- | --- | --- | --- | --- |
| POST | `/api/directory/buildings` | Body: `{ "name": "Nexora Residences", "address": "Av. Javier Prado 1234" }` | `201 Created` with `BuildingDirectory` entity; `400` on failure. Expected fields include `id`, `name`, `address`, and audit fields. | Admin/setup screen to register buildings. |
| POST | `/api/directory/apartments` | Body: `{ "buildingId": 1, "code": "101" }` | `201 Created` with `Apartment` entity; `400` on failure. Expected fields include `id`, `buildingId`, `code`, `residentId`, and audit fields. | Admin/setup screen to create apartment units. |
| PUT | `/api/directory/apartments/{id}/resident` | Path: `id` apartment ID. Body: `{ "userId": 1, "fullName": "Juan Perez", "documentNumber": "12345678", "email": "juan@nexora.com", "phone": "+51999888666" }` | `200 OK` with updated `Apartment`; `400` on failure. | Assign an IAM user/resident profile to an apartment. |
| GET | `/api/directory/apartments/{id}/resident` | Path: `id` apartment ID. | `200 OK` with `{ "id": 1, "userId": 1, "fullName": "...", "documentNumber": "...", "email": "...", "phone": "..." }`; `404` if not found. | Resolve resident contact/profile details for an apartment. |
| PUT | `/api/directory/residents/{id}/contact` | Path: `id` resident profile ID. Body: `{ "email": "new.email@nexora.com", "phone": "+51999888666" }` | `200 OK` with updated `ResidentDirectoryProfile`; `400` on failure. | Resident profile screen to update contact data. |

## Bounded Context: Intercom

Folder: `intercom`

Purpose: visitor requests, doorbell IoT ingress, resident decisions, pre-registered visits, queue management, and notification history.

| Method | Path | Request | Response | Mobile use |
| --- | --- | --- | --- | --- |
| POST | `/api/intercom/pre-registered-visits` | Body: `{ "residentId": 1, "visitorName": "Patricia Ruiz", "visitorDocument": "45678912", "expectedAt": "2026-06-12T19:30:00" }` | `201 Created` with `PreRegisteredVisit`; `400` on failure. Fields include `id`, `residentId`, `visitorName`, `visitorDocument`, `expectedAt`, `active`, and audit fields. | Resident creates an expected visitor pass. |
| PUT | `/api/intercom/pre-registered-visits/{id}` | Path: `id` pre-registered visit ID. Body uses the same shape as create. | `200 OK` with updated `PreRegisteredVisit`; `400` on failure. | Edit an expected visit. |
| DELETE | `/api/intercom/pre-registered-visits/{id}` | Path: `id` pre-registered visit ID. | `200 OK` with text `"Pre-registered visit canceled successfully"`. | Cancel an expected visitor pass. |
| POST | `/api/intercom/visit-requests` | Body: `{ "visitorName": "Visitor Name", "apartmentId": 1 }` | `201 Created` with `{ "id": 1, "visitorName": "...", "apartmentId": 1, "status": "PENDING", "photoUrl": null, "audioUrl": null, "createdAt": "..." }`; `400` on failure. | IoT/doorbell creates a visit request when someone rings an apartment. |
| POST | `/api/intercom/visit-requests/{id}/evidence` | Path: `id` visit request ID. Body: `{ "photoUrl": "https://storage.nexora.com/photo/123.jpg", "audioUrl": "https://storage.nexora.com/audio/123.mp3" }` | `200 OK` with visit request detail; `400` on failure. | Attach visitor photo/audio evidence to a pending visit. `audioUrl` is optional. |
| GET | `/api/intercom/queue/pending` | No body. | `200 OK` with `List<IntercomQueueItem>`. Fields include `id`, `visitRequestId`, `assignedDoormanId`, `enqueuedAt`, `status`, and audit fields. | Doorman/operations view for pending door requests. |
| GET | `/api/intercom/visit-requests/{id}` | Path: `id` visit request ID. | `200 OK` with visit request detail; `404` if not found. | Show full detail for a visitor request. |
| POST | `/api/intercom/visit-requests/{id}/decision` | Path: `id` visit request ID. Body: `{ "decision": "APPROVED" }` or `{ "decision": "REJECTED" }` | `200 OK` with visit request detail; `400` on failure. | Resident approves or rejects a visitor. |
| GET | `/api/intercom/notifications/apartment/{id}` | Path: `id` apartment ID. | `200 OK` with list of `{ "id": 1, "status": "...", "sentAt": "...", "isRead": false }`. | Show notification history for an apartment/resident. |
| PUT | `/api/intercom/notifications/{id}/read` | Path: `id` notification ID. | `200 OK` with text `"Notification marked as read"`. | Mark a mobile notification as read. |

Visit request detail response shape:

```json
{
  "id": 1,
  "visitorName": "Visitor Name",
  "apartmentId": 1,
  "status": "PENDING",
  "photoUrl": "https://storage.nexora.com/photo/123.jpg",
  "audioUrl": "https://storage.nexora.com/audio/123.mp3",
  "createdAt": "2026-06-12T19:30:00"
}
```

Observed visit statuses in the domain: `PENDING`, `NOTIFIED`, `APPROVED`, `REJECTED`, `CLOSED`.

## Bounded Context: Security

Folder: `security`

Purpose: door lock/unlock commands, physical sensor ingress, IoT media privacy settings, alarm triggering, and role permission checks.

| Method | Path | Request | Response | Mobile use |
| --- | --- | --- | --- | --- |
| POST | `/api/security/alarms/tampering` | No body. | `201 Created` with `SecurityAlarm`; `400` on failure. Fields include `id`, `sensorType`, `status`, `triggeredAt`, and audit fields. | Trigger or test a tampering/vibration alarm event. |
| POST | `/api/security/iot/presence` | No body. | `200 OK` with text `"Presence processed successfully"`. | IoT ingress for ultrasonic/person-presence detection near the door. |
| POST | `/api/security/iot/media/toggle` | Body: `{ "deviceCode": "DEV-ESP32-DOOR01", "camera": false, "microphone": false }` | `200 OK` with `IoTDevice`; `400` on failure. Fields include `id`, `deviceCode`, `cameraEnabled`, `microphoneEnabled`, `status`, and audit fields. | Privacy toggle for camera/microphone streams. |
| POST | `/api/security/door/unlock` | No body. | `200 OK` with `{ "id": 1, "commandType": "UNLOCK", "status": "PENDING", "dispatchedAt": "...", "confirmedAt": null }`; `400` on failure. | Send an unlock command to the physical door. |
| POST | `/api/security/door/lock` | No body. | `200 OK` with `{ "id": 1, "commandType": "LOCK", "status": "PENDING", "dispatchedAt": "...", "confirmedAt": null }`; `400` on failure. | Send a lock command to the physical door. |
| POST | `/api/security/authorize` | Body: `{ "role": "DOORMAN", "permissionCode": "CAN_AUTHORIZE" }` | `200 OK` with boolean `true` or `false`. | Check whether a role has a functional permission before showing/enabling a UI action. |

Observed door command statuses in the domain: `PENDING`, `DISPATCHED`, `CONFIRMED`, `FAILED`.

Observed alarm statuses in the domain: `TRIGGERED`, `ACKNOWLEDGED`, `RESOLVED`.

## Bounded Context: Audit

Folder: `audit`

Purpose: immutable access records, access history queries, and hardware activity logs.

| Method | Path | Request | Response | Mobile use |
| --- | --- | --- | --- | --- |
| POST | `/api/audit/access-records` | Body: `{ "correlationId": "1", "decision": "APPROVED" }` | `201 Created` with access record resource; `400` on failure. | Explicitly create a sealed access audit record after a decision/action. |
| GET | `/api/audit/access-records/{id}` | Path: `id` access record ID. | `200 OK` with access record resource; `404` if not found. | Show one detailed audit record. |
| GET | `/api/audit/access-records` | No body. | `200 OK` with list of access record resources. | Display/search the global access audit log. |
| GET | `/api/audit/access-records/resident/{id}` | Path: `id` resident profile ID. | `200 OK` with list of access record resources. | Show a resident's access history. |
| GET | `/api/audit/hardware-logs` | No body. | `200 OK` with list of `AccessTimelineEntry`. Fields include `id`, `eventDescription`, `timestamp`, and audit fields. | Display hardware activity timeline, such as door commands and status changes. |

Access record response shape:

```json
{
  "id": 1,
  "correlationId": "1",
  "decision": "APPROVED",
  "isSealed": true,
  "timeline": [
    "2026-06-12T19:30:00 - Door unlocked"
  ],
  "createdAt": "2026-06-12T19:30:00"
}
```

## Suggested Flutter Integration Prompt

Build a Flutter mobile frontend that integrates with this NexBell backend. Organize API clients and repositories by bounded context: IAM, Directory, Intercom, Security, and Audit. Use the endpoint tables above as the source of truth for HTTP methods, paths, request bodies, path/query parameters, and response models. Model enums explicitly for roles, access decisions, and command types. Store session tokens returned by IAM login/refresh, but do not block calls on authorization because the backend currently permits all requests. Implement resident-facing flows for login, profile/contact update, pre-registering visitors, receiving visit request details, approving/rejecting visitors, notification history/read status, and audit history. Implement doorman/admin-facing flows for pending intercom queue, door lock/unlock, building/apartment setup, resident assignment, device media toggles, permission checks, security alarms, and hardware logs.
