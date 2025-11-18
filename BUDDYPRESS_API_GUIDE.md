# BuddyPress REST API Guide for GRead.fun

## Table of Contents

- [Introduction](#introduction)
- [Base URL](#base-url)
- [Authentication](#authentication)
- [Common Patterns](#common-patterns)
- [Endpoints](#endpoints)
  - [Activity](#activity-endpoints)
  - [Members](#members-endpoints)
  - [Groups](#groups-endpoints)
  - [Group Membership](#group-membership-endpoints)
  - [Group Invites](#group-invites-endpoints)
  - [Messages](#messages-endpoints)
  - [Friends](#friends-endpoints)
  - [Notifications](#notifications-endpoints)
  - [XProfile](#xprofile-endpoints)
  - [Signup](#signup-endpoints)
  - [Components](#components-endpoints)
  - [Attachments](#attachments-endpoints)
  - [Blogs](#blogs-endpoints)
- [Error Handling](#error-handling)
- [Response Headers](#response-headers)

---

## Introduction

This is the comprehensive API documentation for the BuddyPress REST API implementation on **gread.fun**. The API provides RESTful access to all BuddyPress features including activity streams, user profiles, groups, messaging, friendships, and more.

**API Version:** v1
**Base Namespace:** `buddypress/v1`

---

## Base URL

All API requests should be made to:

```
https://gread.fun/wp-json/buddypress/v1/
```

---

## Authentication

The GRead.fun BuddyPress API uses **JWT (JSON Web Token)** authentication.

### Obtaining a JWT Token

First, you need to authenticate and receive a JWT token:

```bash
curl -X POST "https://gread.fun/wp-json/jwt-auth/v1/token" \
  -H "Content-Type: application/json" \
  -d '{
    "username": "your_username",
    "password": "your_password"
  }'
```

**Response:**
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user_email": "user@example.com",
  "user_nicename": "username",
  "user_display_name": "Display Name"
}
```

### Using the JWT Token

Include the token in the `Authorization` header of all authenticated requests:

```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/activity" \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
```

### Public vs Protected Endpoints

- **Public Endpoints**: Can be accessed without authentication (e.g., listing members, viewing public activity)
- **Protected Endpoints**: Require authentication (e.g., posting activity, sending messages, managing profile)

---

## Common Patterns

### Pagination

Most collection endpoints support pagination:

- `page` - Page number (default: 1)
- `per_page` - Items per page (default: 10, max: 100)

```bash
curl "https://gread.fun/wp-json/buddypress/v1/members?page=2&per_page=20"
```

### Search

Many endpoints support search:

```bash
curl "https://gread.fun/wp-json/buddypress/v1/members?search=john"
```

### Context

Control the detail level of responses:

- `view` - Default context (public data)
- `edit` - Includes all fields for editing
- `embed` - Minimal data for embedding

```bash
curl "https://gread.fun/wp-json/buddypress/v1/members/123?context=edit" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Ordering

- `order` - Sort direction (`asc` or `desc`)
- `orderby` - Field to sort by (varies by endpoint)

```bash
curl "https://gread.fun/wp-json/buddypress/v1/activity?order=asc&orderby=date_recorded"
```

---

## Endpoints

## Activity Endpoints

The Activity component manages activity streams, updates, and comments.

**Base Endpoint:** `/buddypress/v1/activity`

### List Activities

Retrieve a list of activities.

**Endpoint:** `GET /buddypress/v1/activity`

**Authentication:** Public (optional)

**Parameters:**
- `page` (integer) - Page number (default: 1)
- `per_page` (integer) - Items per page (default: 10, max: 100)
- `search` (string) - Search term
- `user_id` (integer) - Filter by user ID
- `group_id` (integer) - Filter by group ID
- `component` (string) - Filter by component (activity, groups, members, etc.)
- `type` (array) - Filter by activity type
- `scope` (string) - Filter scope: `just-me`, `friends`, `groups`, `favorites`, `mentions`
- `status` (string) - Filter status: `ham_only`, `spam_only`, `all` (default: ham_only)
- `display_comments` (string) - Comment display: `stream`, `threaded`, or empty
- `order` (string) - Sort order: `asc` or `desc` (default: desc)
- `after` (string) - Filter activities after date (ISO8601 format)
- `include` (array) - Include specific activity IDs
- `exclude` (array) - Exclude specific activity IDs

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/activity?per_page=5&component=activity"
```

**Example Response:**
```json
{
  "activities": [
    {
      "id": 345,
      "user_id": 7,
      "component": "activity",
      "type": "activity_update",
      "action": "<a href=\"https://gread.fun/users/gggg/\">G</a> posted an update",
      "content": "Leviathan reminds me of "supernatural" the tv show…..",
      "primary_link": "https://gread.fun/users/gggg/",
      "item_id": 0,
      "secondary_item_id": 0,
      "date_recorded": "2025-11-17 22:52:13",
      "hide_sitewide": 0,
      "is_spam": 0,
      "user_email": "user@example.com",
      "user_nicename": "gggg",
      "user_login": "GGGG",
      "display_name": "G",
      "user_fullname": "G",
      "children": []
    }
  ],
  "total": 120,
  "pages": 24
}
```

### Get Single Activity

Retrieve a specific activity item.

**Endpoint:** `GET /buddypress/v1/activity/{id}`

**Authentication:** Public (optional)

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/activity/345"
```

### Create Activity

Post a new activity update.

**Endpoint:** `POST /buddypress/v1/activity`

**Authentication:** Required

**Parameters:**
- `content` (string) - The activity content (required)
- `component` (string) - Component name (optional)
- `type` (string) - Activity type (optional)
- `primary_item_id` (integer) - Primary associated item ID (optional)
- `secondary_item_id` (integer) - Secondary associated item ID (optional)
- `link` (string) - Permalink URL (optional)
- `hidden` (boolean) - Hide sitewide (optional)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/buddypress/v1/activity" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Just finished reading an amazing book!",
    "component": "activity",
    "type": "activity_update"
  }'
```

**Example Response:**
```json
{
  "id": 346,
  "user_id": 4,
  "component": "activity",
  "type": "activity_update",
  "content": "Just finished reading an amazing book!",
  "date_recorded": "2025-11-18 10:30:00",
  "hide_sitewide": 0,
  "is_spam": 0
}
```

### Update Activity

Update an existing activity item.

**Endpoint:** `PUT /buddypress/v1/activity/{id}`

**Authentication:** Required (must be activity owner or admin)

**Parameters:**
- `content` (string) - Updated content
- `hidden` (boolean) - Hide/unhide sitewide

**Example Request:**
```bash
curl -X PUT "https://gread.fun/wp-json/buddypress/v1/activity/346" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Updated: Just finished reading an amazing book! Highly recommend it."
  }'
```

### Delete Activity

Delete an activity item.

**Endpoint:** `DELETE /buddypress/v1/activity/{id}`

**Authentication:** Required (must be activity owner or admin)

**Example Request:**
```bash
curl -X DELETE "https://gread.fun/wp-json/buddypress/v1/activity/346" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Favorite/Unfavorite Activity

Toggle favorite status on an activity item.

**Endpoint:** `POST /buddypress/v1/activity/{id}/favorite`

**Authentication:** Required

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/buddypress/v1/activity/345/favorite" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Example Response:**
```json
{
  "favorited": true,
  "favorite_count": 5
}
```

### Add Activity Comment

Add a comment to an activity item.

**Endpoint:** `POST /buddypress/v1/activity/{id}/comment`

**Authentication:** Required

**Parameters:**
- `content` (string) - Comment content (required)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/buddypress/v1/activity/345/comment" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "I agree! That show is amazing."
  }'
```

---

## Members Endpoints

The Members component manages user accounts and profiles.

**Base Endpoint:** `/buddypress/v1/members`

### List Members

Retrieve a list of members.

**Endpoint:** `GET /buddypress/v1/members`

**Authentication:** Public

**Parameters:**
- `page` (integer) - Page number (default: 1)
- `per_page` (integer) - Items per page (default: 10, max: 100)
- `search` (string) - Search members
- `type` (string) - Member type: `active`, `newest`, `alphabetical`, `random`, `online`, `popular` (default: newest)
- `user_id` (integer) - Limit to friends of this user
- `user_ids` (array) - Specific user IDs to include
- `include` (array) - Include specific member IDs
- `exclude` (array) - Exclude specific member IDs
- `populate_extras` (boolean) - Include extra BP data (default: false)
- `member_type` (array) - Filter by member type
- `xprofile` (object/array) - Filter by XProfile field values

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/members?per_page=5&type=active"
```

**Example Response:**
```json
[
  {
    "id": 2,
    "name": "daniel",
    "avatar": "<img loading=\"lazy\" src=\"https://gread.fun/wp-content/uploads/avatars/2/1760138793-bpfull.png\" class=\"avatar user-2-avatar avatar-150 photo\" width=\"150\" height=\"150\" alt=\"Profile picture of daniel\" />",
    "link": "https://gread.fun/users/daniel/",
    "last_active": "Active 14 hours, 9 minutes ago"
  },
  {
    "id": 4,
    "name": "BryceDyce",
    "avatar": "<img loading=\"lazy\" src=\"https://gread.fun/wp-content/uploads/avatars/4/1760913305-bpfull.jpg\" class=\"avatar user-4-avatar avatar-150 photo\" width=\"150\" height=\"150\" alt=\"Profile picture of BryceDyce\" />",
    "link": "https://gread.fun/users/brycedyce/",
    "last_active": "Active 17 hours, 54 minutes ago"
  }
]
```

### Get Single Member

Retrieve a specific member's details.

**Endpoint:** `GET /buddypress/v1/members/{id}`

**Authentication:** Public (more details with auth)

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/members/4"
```

### Get Current User

Retrieve the currently authenticated user's details.

**Endpoint:** `GET /buddypress/v1/members/me`

**Authentication:** Required

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/members/me" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Create Member

Register a new member account.

**Endpoint:** `POST /buddypress/v1/members`

**Authentication:** Admin required (or open registration)

**Parameters:**
- `user_login` (string) - Username (required)
- `password` (string) - Password (required)
- `email` (string) - Email address (required)
- `name` (string) - Display name (optional)
- `roles` (array) - User roles (optional)
- `member_type` (string) - Member type (optional)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/buddypress/v1/members" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_login": "newuser123",
    "password": "SecurePass123!",
    "email": "newuser@example.com",
    "name": "New User"
  }'
```

### Update Member

Update member information.

**Endpoint:** `PUT /buddypress/v1/members/{id}`

**Authentication:** Required (must be the user or admin)

**Parameters:**
- `name` (string) - Display name
- `roles` (array) - User roles (admin only)
- `member_type` (string) - Member type

**Example Request:**
```bash
curl -X PUT "https://gread.fun/wp-json/buddypress/v1/members/4" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Name"
  }'
```

### Delete Member

Delete a member account.

**Endpoint:** `DELETE /buddypress/v1/members/{id}`

**Authentication:** Required (must be the user or admin)

**Example Request:**
```bash
curl -X DELETE "https://gread.fun/wp-json/buddypress/v1/members/123" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Get Member XProfile Data

Retrieve a member's XProfile (extended profile) data.

**Endpoint:** `GET /buddypress/v1/members/{id}/xprofile`

**Authentication:** Public (visibility rules apply)

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/members/4/xprofile"
```

### Update Member XProfile Data

Update a member's XProfile data.

**Endpoint:** `PUT /buddypress/v1/members/{id}/xprofile`

**Authentication:** Required (must be the user or admin)

**Example Request:**
```bash
curl -X PUT "https://gread.fun/wp-json/buddypress/v1/members/4/xprofile" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": [
      {
        "id": 1,
        "value": "My updated bio"
      }
    ]
  }'
```

---

## Groups Endpoints

The Groups component manages BuddyPress groups.

**Base Endpoint:** `/buddypress/v1/groups`

### List Groups

Retrieve a list of groups.

**Endpoint:** `GET /buddypress/v1/groups`

**Authentication:** Public

**Parameters:**
- `page` (integer) - Page number (default: 1)
- `per_page` (integer) - Items per page (default: 10, max: 100)
- `search` (string) - Search groups
- `type` (string) - Group type: `active`, `newest`, `alphabetical`, `random`, `popular` (default: active)
- `order` (string) - Sort order: `asc` or `desc` (default: desc)
- `orderby` (string) - Order by: `date_created`, `last_activity`, `total_member_count`, `name`, `random`
- `status` (array) - Group status: `public`, `private`, `hidden`
- `user_id` (integer) - Filter by user membership
- `parent_id` (array) - Filter by parent group ID
- `include` (array) - Include specific group IDs
- `exclude` (array) - Exclude specific group IDs
- `group_type` (string) - Filter by group type
- `enable_forum` (boolean) - Filter by forum enabled
- `show_hidden` (boolean) - Include hidden groups (default: false)
- `populate_extras` (boolean) - Include extra BP data (default: false)

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/groups?per_page=5&type=active"
```

**Example Response:**
```json
{
  "groups": [
    {
      "id": 2,
      "creator_id": 3,
      "name": "madwickeddonkeylovers",
      "slug": "madwickeddonkeylovers",
      "description": "madwickeddonkeylovers",
      "status": "public",
      "parent_id": 0,
      "enable_forum": 0,
      "date_created": "2025-09-22 20:26:21"
    },
    {
      "id": 1,
      "creator_id": 1,
      "name": "Developers",
      "slug": "developers",
      "description": "This group includes all the developers of GRead.",
      "status": "private",
      "parent_id": 0,
      "enable_forum": 0,
      "date_created": "2025-09-22 15:58:54"
    }
  ],
  "total": 2
}
```

### Get Single Group

Retrieve a specific group's details.

**Endpoint:** `GET /buddypress/v1/groups/{id}`

**Authentication:** Public (for public/private groups)

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/groups/1"
```

### Get Current User's Groups

Retrieve groups for the authenticated user.

**Endpoint:** `GET /buddypress/v1/groups/me`

**Authentication:** Required

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/groups/me" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Create Group

Create a new group.

**Endpoint:** `POST /buddypress/v1/groups`

**Authentication:** Required

**Parameters:**
- `name` (string) - Group name (required)
- `description` (string/object) - Group description (required)
- `slug` (string) - URL-friendly slug (optional, auto-generated)
- `status` (string) - Group status: `public`, `private`, `hidden` (default: public)
- `creator_id` (integer) - Creator user ID (default: current user)
- `enable_forum` (boolean) - Enable group forum (optional)
- `parent_id` (integer) - Parent group ID (optional)
- `types` (string) - Group types, comma-separated (optional)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/buddypress/v1/groups" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Book Lovers",
    "description": "A group for people who love reading",
    "status": "public",
    "enable_forum": false
  }'
```

**Example Response:**
```json
{
  "id": 3,
  "creator_id": 4,
  "name": "Book Lovers",
  "slug": "book-lovers",
  "description": "A group for people who love reading",
  "status": "public",
  "parent_id": 0,
  "enable_forum": 0,
  "date_created": "2025-11-18 10:45:00"
}
```

### Update Group

Update group information.

**Endpoint:** `PUT /buddypress/v1/groups/{id}`

**Authentication:** Required (must be group admin)

**Parameters:**
- `name` (string) - Group name
- `description` (string/object) - Group description
- `status` (string) - Group status: `public`, `private`, `hidden`
- `enable_forum` (boolean) - Enable group forum
- `parent_id` (integer) - Parent group ID

**Example Request:**
```bash
curl -X PUT "https://gread.fun/wp-json/buddypress/v1/groups/3" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Updated description for book lovers group",
    "status": "private"
  }'
```

### Delete Group

Delete a group.

**Endpoint:** `DELETE /buddypress/v1/groups/{id}`

**Authentication:** Required (must be group admin)

**Example Request:**
```bash
curl -X DELETE "https://gread.fun/wp-json/buddypress/v1/groups/3" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Group Membership Endpoints

Manage group members and their roles.

**Base Endpoint:** `/buddypress/v1/groups/{group_id}/members`

### List Group Members

Retrieve members of a group.

**Endpoint:** `GET /buddypress/v1/groups/{group_id}/members`

**Authentication:** Public (for public groups)

**Parameters:**
- `page` (integer) - Page number
- `per_page` (integer) - Items per page
- `status` (string) - Member status filter
- `roles` (array) - Filter by role: `admin`, `mod`, `member`, `banned`
- `exclude_admins` (boolean) - Exclude group admins
- `exclude_banned` (boolean) - Exclude banned members

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/groups/1/members?per_page=10"
```

### Add Group Member

Add a member to a group.

**Endpoint:** `POST /buddypress/v1/groups/{group_id}/members/{user_id}`

**Authentication:** Required

**Parameters:**
- `action` (string) - Action to perform: `join`, `request_membership`
- `role` (string) - Member role (admin only): `admin`, `mod`, `member`

**Example Request:**
```bash
# Join a public group
curl -X POST "https://gread.fun/wp-json/buddypress/v1/groups/1/members/4" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "join"
  }'
```

### Update Group Member

Update a member's role or status in a group.

**Endpoint:** `PUT /buddypress/v1/groups/{group_id}/members/{user_id}`

**Authentication:** Required (must be group admin)

**Parameters:**
- `role` (string) - New role: `admin`, `mod`, `member`
- `action` (string) - Action: `promote`, `demote`, `ban`, `unban`

**Example Request:**
```bash
curl -X PUT "https://gread.fun/wp-json/buddypress/v1/groups/1/members/5" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "role": "mod"
  }'
```

### Remove Group Member

Remove a member from a group.

**Endpoint:** `DELETE /buddypress/v1/groups/{group_id}/members/{user_id}`

**Authentication:** Required (must be the user, group admin, or site admin)

**Example Request:**
```bash
curl -X DELETE "https://gread.fun/wp-json/buddypress/v1/groups/1/members/5" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Group Invites Endpoints

Manage group invitations.

**Base Endpoint:** `/buddypress/v1/groups/{group_id}/invites`

### List Group Invites

Retrieve invites for a group.

**Endpoint:** `GET /buddypress/v1/groups/{group_id}/invites`

**Authentication:** Required (must be group member)

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/groups/1/invites" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Send Group Invite

Send an invitation to join a group.

**Endpoint:** `POST /buddypress/v1/groups/{group_id}/invites`

**Authentication:** Required (must be group member)

**Parameters:**
- `user_id` (integer) - User ID to invite (required)
- `invite_message` (string) - Custom invitation message (optional)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/buddypress/v1/groups/1/invites" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 6,
    "invite_message": "Join our awesome group!"
  }'
```

### Get Specific Invite

Retrieve a specific group invite.

**Endpoint:** `GET /buddypress/v1/groups/{group_id}/invites/{user_id}`

**Authentication:** Required

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/groups/1/invites/6" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Accept/Reject Invite

Accept or reject a group invitation.

**Endpoint:** `PUT /buddypress/v1/groups/{group_id}/invites/{user_id}`

**Authentication:** Required (must be invited user)

**Parameters:**
- `action` (string) - Action: `accept` or `reject`

**Example Request:**
```bash
curl -X PUT "https://gread.fun/wp-json/buddypress/v1/groups/1/invites/6" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "accept"
  }'
```

### Delete Invite

Cancel/delete a group invitation.

**Endpoint:** `DELETE /buddypress/v1/groups/{group_id}/invites/{user_id}`

**Authentication:** Required (must be inviter or invitee)

**Example Request:**
```bash
curl -X DELETE "https://gread.fun/wp-json/buddypress/v1/groups/1/invites/6" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Messages Endpoints

The Messages component manages private messaging between members.

**Base Endpoint:** `/buddypress/v1/messages`

### List Message Threads

Retrieve message threads for the authenticated user.

**Endpoint:** `GET /buddypress/v1/messages`

**Authentication:** Required

**Parameters:**
- `page` (integer) - Page number
- `per_page` (integer) - Items per page
- `box` (string) - Message box: `inbox`, `sentbox`, `starred` (default: inbox)
- `type` (string) - Thread status: `all`, `read`, `unread` (default: all)
- `user_id` (integer) - User ID (required, usually current user)
- `search` (string) - Search messages
- `recipients_page` (integer) - Recipients pagination page
- `recipients_per_page` (integer) - Recipients per page
- `messages_page` (integer) - Messages pagination page
- `messages_per_page` (integer) - Messages per page

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/messages?user_id=4&box=inbox&per_page=10" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Get Single Thread

Retrieve a specific message thread.

**Endpoint:** `GET /buddypress/v1/messages/{thread_id}`

**Authentication:** Required (must be thread participant)

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/messages/15" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Send Message / Create Thread

Send a new message or create a new thread.

**Endpoint:** `POST /buddypress/v1/messages`

**Authentication:** Required

**Parameters:**
- `message` (string) - Message content (required)
- `recipients` (array) - Array of recipient user IDs (required for new threads)
- `subject` (string) - Thread subject (required for new threads)
- `id` (integer) - Thread ID (required when replying to existing thread)
- `sender_id` (integer) - Sender user ID (optional, defaults to current user)

**Example Request (New Thread):**
```bash
curl -X POST "https://gread.fun/wp-json/buddypress/v1/messages" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "subject": "Book Recommendation",
    "message": "Hey! Have you read the new sci-fi novel?",
    "recipients": [5, 7]
  }'
```

**Example Request (Reply to Thread):**
```bash
curl -X POST "https://gread.fun/wp-json/buddypress/v1/messages" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "id": 15,
    "message": "Yes! It was amazing!"
  }'
```

### Update Thread

Update thread status (mark as read/unread).

**Endpoint:** `PUT /buddypress/v1/messages/{thread_id}`

**Authentication:** Required (must be thread participant)

**Parameters:**
- `read` (boolean) - Mark thread as read (true) or unread (false)

**Example Request:**
```bash
curl -X PUT "https://gread.fun/wp-json/buddypress/v1/messages/15" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "read": true
  }'
```

### Delete Thread

Delete a message thread.

**Endpoint:** `DELETE /buddypress/v1/messages/{thread_id}`

**Authentication:** Required (must be thread participant)

**Example Request:**
```bash
curl -X DELETE "https://gread.fun/wp-json/buddypress/v1/messages/15" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Star/Unstar Message

Toggle star status on a specific message.

**Endpoint:** `PUT /buddypress/v1/messages/starred/{message_id}`

**Authentication:** Required

**Example Request:**
```bash
curl -X PUT "https://gread.fun/wp-json/buddypress/v1/messages/starred/234" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Friends Endpoints

The Friends component manages friendships and friend requests.

**Base Endpoint:** `/buddypress/v1/friends`

### List Friendships

Retrieve friendships for a user.

**Endpoint:** `GET /buddypress/v1/friends`

**Authentication:** Public (limited) / Required (full access)

**Parameters:**
- `page` (integer) - Page number
- `per_page` (integer) - Items per page
- `user_id` (integer) - User ID to get friendships for
- `is_confirmed` (boolean) - Filter by confirmed status
- `order` (string) - Sort order: `asc` or `desc`
- `orderby` (string) - Order by field

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/friends?user_id=4&per_page=20" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Get Friendship

Retrieve a specific friendship.

**Endpoint:** `GET /buddypress/v1/friends/{id}`

**Authentication:** Required

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/friends/42" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Create Friendship Request

Send a friend request.

**Endpoint:** `POST /buddypress/v1/friends`

**Authentication:** Required

**Parameters:**
- `initiator_id` (integer) - Initiator user ID (optional, defaults to current user)
- `friend_id` (integer) - Friend user ID (required)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/buddypress/v1/friends" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "friend_id": 8
  }'
```

### Accept/Reject Friendship

Accept or reject a friendship request.

**Endpoint:** `PUT /buddypress/v1/friends/{id}`

**Authentication:** Required (must be recipient)

**Parameters:**
- `action` (string) - Action: `accept` or `reject`

**Example Request:**
```bash
curl -X PUT "https://gread.fun/wp-json/buddypress/v1/friends/42" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "accept"
  }'
```

### Delete Friendship

Remove a friendship.

**Endpoint:** `DELETE /buddypress/v1/friends/{id}`

**Authentication:** Required (must be one of the friends)

**Example Request:**
```bash
curl -X DELETE "https://gread.fun/wp-json/buddypress/v1/friends/42" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Notifications Endpoints

The Notifications component manages user notifications.

**Base Endpoint:** `/buddypress/v1/notifications`

### List Notifications

Retrieve notifications for the authenticated user.

**Endpoint:** `GET /buddypress/v1/notifications`

**Authentication:** Required

**Parameters:**
- `page` (integer) - Page number
- `per_page` (integer) - Items per page
- `user_id` (integer) - User ID (optional, defaults to current user)
- `component_name` (string) - Filter by component
- `component_action` (string) - Filter by component action
- `is_new` (boolean) - Filter by read/unread status
- `order` (string) - Sort order: `asc` or `desc`
- `orderby` (string) - Order by field

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/notifications?is_new=true&per_page=20" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Get Single Notification

Retrieve a specific notification.

**Endpoint:** `GET /buddypress/v1/notifications/{id}`

**Authentication:** Required (must be notification owner)

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/notifications/123" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Create Notification

Create a new notification.

**Endpoint:** `POST /buddypress/v1/notifications`

**Authentication:** Required

**Parameters:**
- `user_id` (integer) - Recipient user ID (required)
- `component_name` (string) - Component name (required)
- `component_action` (string) - Component action (required)
- `item_id` (integer) - Item ID (required)
- `secondary_item_id` (integer) - Secondary item ID (optional)
- `date_notified` (string) - Date in ISO8601 format (optional)
- `is_new` (boolean) - Unread status (optional, default: true)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/buddypress/v1/notifications" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 5,
    "component_name": "activity",
    "component_action": "new_comment",
    "item_id": 345
  }'
```

### Update Notification

Mark a notification as read or unread.

**Endpoint:** `PUT /buddypress/v1/notifications/{id}`

**Authentication:** Required (must be notification owner)

**Parameters:**
- `is_new` (boolean) - Mark as unread (true) or read (false)

**Example Request:**
```bash
curl -X PUT "https://gread.fun/wp-json/buddypress/v1/notifications/123" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "is_new": false
  }'
```

### Delete Notification

Delete a notification.

**Endpoint:** `DELETE /buddypress/v1/notifications/{id}`

**Authentication:** Required (must be notification owner)

**Example Request:**
```bash
curl -X DELETE "https://gread.fun/wp-json/buddypress/v1/notifications/123" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## XProfile Endpoints

The XProfile component manages extended profile fields and data.

### XProfile Field Groups

**Base Endpoint:** `/buddypress/v1/xprofile/groups`

#### List Field Groups

Retrieve XProfile field groups.

**Endpoint:** `GET /buddypress/v1/xprofile/groups`

**Authentication:** Public

**Parameters:**
- `page` (integer) - Page number
- `per_page` (integer) - Items per page
- `fetch_fields` (boolean) - Include fields in response
- `fetch_field_data` (boolean) - Include field data
- `fetch_visibility_level` (boolean) - Include visibility levels
- `user_id` (integer) - User ID for field data

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/xprofile/groups?fetch_fields=true"
```

#### Get Field Group

Retrieve a specific field group.

**Endpoint:** `GET /buddypress/v1/xprofile/groups/{id}`

**Authentication:** Public

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/xprofile/groups/1"
```

#### Create Field Group

Create a new XProfile field group.

**Endpoint:** `POST /buddypress/v1/xprofile/groups`

**Authentication:** Required (admin)

**Parameters:**
- `name` (string) - Group name (required)
- `description` (string) - Group description (optional)
- `can_delete` (boolean) - Whether group can be deleted (optional)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/buddypress/v1/xprofile/groups" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Reading Preferences",
    "description": "Fields related to reading preferences"
  }'
```

#### Update Field Group

Update a field group.

**Endpoint:** `PUT /buddypress/v1/xprofile/groups/{id}`

**Authentication:** Required (admin)

**Example Request:**
```bash
curl -X PUT "https://gread.fun/wp-json/buddypress/v1/xprofile/groups/2" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Group Name"
  }'
```

#### Delete Field Group

Delete a field group.

**Endpoint:** `DELETE /buddypress/v1/xprofile/groups/{id}`

**Authentication:** Required (admin)

**Example Request:**
```bash
curl -X DELETE "https://gread.fun/wp-json/buddypress/v1/xprofile/groups/2" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### XProfile Fields

**Base Endpoint:** `/buddypress/v1/xprofile/fields`

#### List Fields

Retrieve XProfile fields.

**Endpoint:** `GET /buddypress/v1/xprofile/fields`

**Authentication:** Public

**Parameters:**
- `profile_group_id` (integer) - Filter by field group ID
- `hide_empty_groups` (boolean) - Hide groups without fields
- `user_id` (integer) - User ID for field data
- `member_type` (array) - Filter by member type
- `signup_fields_only` (boolean) - Only signup fields
- `fetch_field_data` (boolean) - Include field data
- `fetch_visibility_level` (boolean) - Include visibility

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/xprofile/fields?profile_group_id=1"
```

#### Get Field

Retrieve a specific XProfile field.

**Endpoint:** `GET /buddypress/v1/xprofile/fields/{id}`

**Authentication:** Public

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/xprofile/fields/5"
```

#### Create Field

Create a new XProfile field.

**Endpoint:** `POST /buddypress/v1/xprofile/fields`

**Authentication:** Required (admin)

**Parameters:**
- `group_id` (integer) - Field group ID (required)
- `type` (string) - Field type (required)
- `name` (string) - Field name (required)
- `description` (string) - Field description (optional)
- `is_required` (boolean) - Whether field is required (optional)
- `can_delete` (boolean) - Whether field can be deleted (optional)
- `field_order` (integer) - Display order (optional)
- `option_order` (integer) - Option order for select fields (optional)
- `order_by` (string) - How to order options (optional)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/buddypress/v1/xprofile/fields" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "group_id": 1,
    "type": "textbox",
    "name": "Favorite Genre",
    "description": "What is your favorite book genre?",
    "is_required": false
  }'
```

#### Update Field

Update an XProfile field.

**Endpoint:** `PUT /buddypress/v1/xprofile/fields/{id}`

**Authentication:** Required (admin)

**Example Request:**
```bash
curl -X PUT "https://gread.fun/wp-json/buddypress/v1/xprofile/fields/5" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Updated field description"
  }'
```

#### Delete Field

Delete an XProfile field.

**Endpoint:** `DELETE /buddypress/v1/xprofile/fields/{id}`

**Authentication:** Required (admin)

**Example Request:**
```bash
curl -X DELETE "https://gread.fun/wp-json/buddypress/v1/xprofile/fields/5" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### XProfile Data

**Base Endpoint:** `/buddypress/v1/xprofile/{field_id}/data/{user_id}`

#### Get Field Data

Retrieve XProfile field data for a user.

**Endpoint:** `GET /buddypress/v1/xprofile/{field_id}/data/{user_id}`

**Authentication:** Public (visibility rules apply)

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/xprofile/5/data/4"
```

#### Update Field Data

Update XProfile field data for a user.

**Endpoint:** `PUT /buddypress/v1/xprofile/{field_id}/data/{user_id}`

**Authentication:** Required (must be the user or admin)

**Parameters:**
- `value` (string/array) - Field value (required)

**Example Request:**
```bash
curl -X PUT "https://gread.fun/wp-json/buddypress/v1/xprofile/5/data/4" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "value": "Science Fiction"
  }'
```

#### Delete Field Data

Delete XProfile field data for a user.

**Endpoint:** `DELETE /buddypress/v1/xprofile/{field_id}/data/{user_id}`

**Authentication:** Required (must be the user or admin)

**Example Request:**
```bash
curl -X DELETE "https://gread.fun/wp-json/buddypress/v1/xprofile/5/data/4" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Signup Endpoints

The Signup component manages user registrations and activations.

**Base Endpoint:** `/buddypress/v1/signup`

### List Signups

Retrieve pending signups.

**Endpoint:** `GET /buddypress/v1/signup`

**Authentication:** Required (admin)

**Parameters:**
- `page` (integer) - Page number
- `per_page` (integer) - Items per page
- `include` (array) - Include specific signup IDs
- `user_login` (string) - Filter by username

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/signup?per_page=20" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Get Signup

Retrieve a specific signup.

**Endpoint:** `GET /buddypress/v1/signup/{id}`

**Authentication:** Required (admin)

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/signup/45" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Create Signup

Register a new user (create signup).

**Endpoint:** `POST /buddypress/v1/signup`

**Authentication:** Public (if registration is open)

**Parameters:**
- `user_login` (string) - Username (required)
- `password` (string) - Password (required)
- `user_email` (string) - Email address (required)
- `user_name` (string) - Display name (optional)
- `signup_field_data` (array) - XProfile field data for signup (optional)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/buddypress/v1/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "user_login": "newreader",
    "password": "SecurePass123!",
    "user_email": "newreader@example.com",
    "user_name": "New Reader"
  }'
```

**Example Response:**
```json
{
  "id": 46,
  "user_login": "newreader",
  "user_email": "newreader@example.com",
  "registered": "2025-11-18 11:00:00",
  "activation_key": "abc123def456"
}
```

### Delete Signup

Delete a signup (cancel registration).

**Endpoint:** `DELETE /buddypress/v1/signup/{id}`

**Authentication:** Required (admin)

**Example Request:**
```bash
curl -X DELETE "https://gread.fun/wp-json/buddypress/v1/signup/46" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Activate Account

Activate a user account using activation key.

**Endpoint:** `PUT /buddypress/v1/signup/activate/{activation_key}`

**Authentication:** Public

**Example Request:**
```bash
curl -X PUT "https://gread.fun/wp-json/buddypress/v1/signup/activate/abc123def456"
```

**Example Response:**
```json
{
  "activated": true,
  "user_id": 9,
  "message": "Account activated successfully"
}
```

### Resend Activation Email

Resend the activation email.

**Endpoint:** `PUT /buddypress/v1/signup/resend`

**Authentication:** Public

**Parameters:**
- `user_login` (string) - Username or email (required)

**Example Request:**
```bash
curl -X PUT "https://gread.fun/wp-json/buddypress/v1/signup/resend" \
  -H "Content-Type: application/json" \
  -d '{
    "user_login": "newreader"
  }'
```

---

## Components Endpoints

Manage BuddyPress components (activate/deactivate features).

**Base Endpoint:** `/buddypress/v1/components`

### List Components

Retrieve all BuddyPress components and their status.

**Endpoint:** `GET /buddypress/v1/components`

**Authentication:** Required (admin)

**Parameters:**
- `status` (string) - Filter by status: `active`, `inactive`, `all` (default: all)
- `type` (string) - Filter by type: `required`, `optional`, `retired`

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/components?status=active" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Example Response:**
```json
{
  "components": [
    {
      "name": "activity",
      "status": "active",
      "title": "Activity Streams",
      "description": "Track member activity throughout your site",
      "type": "optional"
    },
    {
      "name": "members",
      "status": "active",
      "title": "Community Members",
      "description": "Manage your community members",
      "type": "required"
    },
    {
      "name": "groups",
      "status": "active",
      "title": "User Groups",
      "description": "Create and manage user groups",
      "type": "optional"
    }
  ]
}
```

### Update Component Status

Activate or deactivate a component.

**Endpoint:** `PUT /buddypress/v1/components`

**Authentication:** Required (admin)

**Parameters:**
- `action` (string) - Action: `activate` or `deactivate` (required)
- `name` (string) - Component name (required)

**Example Request:**
```bash
curl -X PUT "https://gread.fun/wp-json/buddypress/v1/components" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "activate",
    "name": "friends"
  }'
```

---

## Attachments Endpoints

Manage avatars and cover images for members, groups, and blogs.

### Member Avatar

**Base Endpoint:** `/buddypress/v1/members/{user_id}/avatar`

#### Get Member Avatar

Retrieve member avatar information.

**Endpoint:** `GET /buddypress/v1/members/{user_id}/avatar`

**Authentication:** Public

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/members/4/avatar"
```

**Example Response:**
```json
{
  "full": "https://gread.fun/wp-content/uploads/avatars/4/avatar-full.jpg",
  "thumb": "https://gread.fun/wp-content/uploads/avatars/4/avatar-thumb.jpg"
}
```

#### Upload Member Avatar

Upload a new avatar image.

**Endpoint:** `POST /buddypress/v1/members/{user_id}/avatar`

**Authentication:** Required (must be the user or admin)

**Parameters:**
- `file` (file) - Avatar image file (multipart/form-data)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/buddypress/v1/members/4/avatar" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "file=@/path/to/avatar.jpg"
```

#### Delete Member Avatar

Delete member avatar.

**Endpoint:** `DELETE /buddypress/v1/members/{user_id}/avatar`

**Authentication:** Required (must be the user or admin)

**Example Request:**
```bash
curl -X DELETE "https://gread.fun/wp-json/buddypress/v1/members/4/avatar" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Member Cover Image

**Base Endpoint:** `/buddypress/v1/members/{user_id}/cover`

#### Get Member Cover

Retrieve member cover image information.

**Endpoint:** `GET /buddypress/v1/members/{user_id}/cover`

**Authentication:** Public

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/members/4/cover"
```

#### Upload Member Cover

Upload a new cover image.

**Endpoint:** `POST /buddypress/v1/members/{user_id}/cover`

**Authentication:** Required (must be the user or admin)

**Parameters:**
- `file` (file) - Cover image file (multipart/form-data)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/buddypress/v1/members/4/cover" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "file=@/path/to/cover.jpg"
```

#### Delete Member Cover

Delete member cover image.

**Endpoint:** `DELETE /buddypress/v1/members/{user_id}/cover`

**Authentication:** Required (must be the user or admin)

**Example Request:**
```bash
curl -X DELETE "https://gread.fun/wp-json/buddypress/v1/members/4/cover" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Group Avatar

**Base Endpoint:** `/buddypress/v1/groups/{group_id}/avatar`

#### Get Group Avatar

Retrieve group avatar information.

**Endpoint:** `GET /buddypress/v1/groups/{group_id}/avatar`

**Authentication:** Public

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/groups/1/avatar"
```

#### Upload Group Avatar

Upload a new group avatar.

**Endpoint:** `POST /buddypress/v1/groups/{group_id}/avatar`

**Authentication:** Required (must be group admin)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/buddypress/v1/groups/1/avatar" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -F "file=@/path/to/group-avatar.jpg"
```

#### Delete Group Avatar

Delete group avatar.

**Endpoint:** `DELETE /buddypress/v1/groups/{group_id}/avatar`

**Authentication:** Required (must be group admin)

**Example Request:**
```bash
curl -X DELETE "https://gread.fun/wp-json/buddypress/v1/groups/1/avatar" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Group Cover Image

**Base Endpoint:** `/buddypress/v1/groups/{group_id}/cover`

Same pattern as member cover images but for groups.

### Blog Avatar

**Base Endpoint:** `/buddypress/v1/blogs/{blog_id}/avatar`

Same pattern as member/group avatars but for blogs (multisite only).

---

## Blogs Endpoints

The Blogs component manages site tracking in multisite installations.

**Base Endpoint:** `/buddypress/v1/blogs`

### List Blogs

Retrieve a list of tracked blogs.

**Endpoint:** `GET /buddypress/v1/blogs`

**Authentication:** Public

**Parameters:**
- `page` (integer) - Page number
- `per_page` (integer) - Items per page
- `search` (string) - Search blogs
- `type` (string) - Blog type: `active`, `alphabetical`, `newest`, `random`
- `user_id` (integer) - Filter blogs by user membership
- `include_blog_ids` (array) - Include specific blog IDs
- `include` (array) - Include specific IDs

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/blogs?per_page=10&type=active"
```

### Get Single Blog

Retrieve a specific blog's details.

**Endpoint:** `GET /buddypress/v1/blogs/{id}`

**Authentication:** Public

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/buddypress/v1/blogs/1"
```

### Create Blog

Create a new blog (multisite only).

**Endpoint:** `POST /buddypress/v1/blogs`

**Authentication:** Required

**Parameters:**
- `domain` (string) - Blog domain (required)
- `path` (string) - Blog path (required)
- `title` (string) - Blog title (required)
- `user_id` (integer) - Blog owner user ID (optional)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/buddypress/v1/blogs" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "domain": "gread.fun",
    "path": "/myblog/",
    "title": "My Reading Blog"
  }'
```

---

## Error Handling

The API uses standard HTTP status codes and returns error details in JSON format.

### Common HTTP Status Codes

- `200 OK` - Successful GET/PUT request
- `201 Created` - Successful POST request (resource created)
- `204 No Content` - Successful DELETE request
- `400 Bad Request` - Invalid request parameters
- `401 Unauthorized` - Authentication required or failed
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

### Error Response Format

```json
{
  "code": "rest_forbidden",
  "message": "Sorry, you are not allowed to do that.",
  "data": {
    "status": 401
  }
}
```

### Common Error Codes

- `rest_forbidden` - Insufficient permissions
- `rest_invalid_param` - Invalid parameter value
- `rest_missing_callback_param` - Missing required parameter
- `rest_no_route` - Endpoint not found
- `bp_rest_authorization_required` - Authentication required
- `bp_rest_invalid_id` - Invalid resource ID

---

## Response Headers

### Pagination Headers

Collection endpoints include pagination information in response headers:

```
X-WP-Total: 120
X-WP-TotalPages: 12
```

### Other Common Headers

```
Content-Type: application/json; charset=UTF-8
X-Robots-Tag: noindex
X-Content-Type-Options: nosniff
```

### Link Headers

Endpoints include HATEOAS links in the `Link` header:

```
Link: <https://gread.fun/wp-json/buddypress/v1/activity?page=2>; rel="next",
      <https://gread.fun/wp-json/buddypress/v1/activity?page=12>; rel="last"
```

---

## Best Practices

### 1. Use Appropriate HTTP Methods

- `GET` - Retrieve resources (idempotent)
- `POST` - Create new resources
- `PUT` - Update existing resources (idempotent)
- `DELETE` - Delete resources (idempotent)

### 2. Handle Pagination

Always use pagination for collections to avoid performance issues:

```bash
curl "https://gread.fun/wp-json/buddypress/v1/members?per_page=20&page=1"
```

### 3. Use Context Parameter

Request only the data you need:

- Use `context=view` for displaying data
- Use `context=edit` when editing (includes all fields)
- Use `context=embed` for minimal data

### 4. Filter Results

Use query parameters to filter results at the API level:

```bash
curl "https://gread.fun/wp-json/buddypress/v1/activity?user_id=4&component=activity"
```

### 5. Secure Your Tokens

- Store JWT tokens securely
- Never expose tokens in client-side code
- Implement token refresh mechanism
- Use HTTPS for all API requests

### 6. Handle Errors Gracefully

Always check response status codes and handle errors appropriately:

```bash
response=$(curl -s -w "\n%{http_code}" "https://gread.fun/wp-json/buddypress/v1/activity")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -eq 200 ]; then
  echo "Success: $body"
else
  echo "Error (HTTP $http_code): $body"
fi
```

### 7. Use Batch Requests

The API supports batch requests (WordPress 5.6+) for multiple operations:

```bash
curl -X POST "https://gread.fun/wp-json/batch/v1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "requests": [
      {
        "path": "/buddypress/v1/activity",
        "method": "GET"
      },
      {
        "path": "/buddypress/v1/members/me",
        "method": "GET"
      }
    ]
  }'
```

---

## Rate Limiting

Check with the site administrator for any rate limiting policies. Generally:

- Implement exponential backoff for failed requests
- Cache responses when appropriate
- Avoid making unnecessary API calls
- Use webhooks/notifications when available instead of polling

---

## Support and Resources

- **BuddyPress Documentation:** https://codex.buddypress.org/
- **WordPress REST API Handbook:** https://developer.wordpress.org/rest-api/
- **GRead.fun Support:** Contact site administrators

---

## Changelog

**Version 1.0** (November 2025)
- Initial comprehensive API guide
- Documented all BuddyPress REST API v1 endpoints
- Added cURL examples for all endpoints
- Included authentication guide for JWT

---

*This guide was created for the BuddyPress REST API implementation at gread.fun. Last updated: November 18, 2025*
