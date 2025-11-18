# GRead Custom API Guide

## Table of Contents

- [Introduction](#introduction)
- [Base URL](#base-url)
- [Authentication](#authentication)
- [Endpoints Overview](#endpoints-overview)
- [Core Endpoints](#core-endpoints)
  - [Members](#members-endpoints)
  - [Activity](#activity-endpoints)
  - [Groups](#groups-endpoints)
  - [Messages](#messages-endpoints)
  - [Notifications](#notifications-endpoints)
  - [Friends](#friends-endpoints)
- [GRead-Specific Features](#gread-specific-features)
  - [Achievements System](#achievements-system)
  - [Mentions System](#mentions-system)
  - [Books & Library](#books--library-system)
  - [User Moderation](#user-moderation-system)
  - [ISBN Management](#isbn-management)
  - [User Statistics](#user-statistics)
  - [Signup](#signup-endpoints)
- [Error Handling](#error-handling)
- [Rate Limiting](#rate-limiting)

---

## Introduction

The GRead Custom API (`gread/v1`) is a specialized REST API built for the GRead.fun reading social network. It provides enhanced endpoints that wrap and extend the standard BuddyPress API with GRead-specific features including:

- **Achievements System** - Gamification with badges and leaderboards
- **Mentions System** - Enhanced user mention functionality
- **Books & Library Management** - ISBN lookup, book tracking, reading progress
- **User Moderation** - Block, mute, and report functionality
- **Enhanced Social Features** - Optimized versions of BuddyPress endpoints

**API Version:** v1
**Namespace:** `gread/v1`

---

## Base URL

All API requests should be made to:

```
https://gread.fun/wp-json/gread/v1/
```

---

## Authentication

The GRead API uses **JWT (JSON Web Token)** authentication, identical to the BuddyPress API.

### Obtaining a JWT Token

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

Include the token in the `Authorization` header:

```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/me/achievements" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Endpoint Access Levels

- 🌐 **Public** - No authentication required
- 🔒 **Protected** - Authentication required
- 👑 **Admin** - Administrator privileges required

---

## Endpoints Overview

The GRead API provides endpoints in the following categories:

| Category | Description | Endpoint Count |
|----------|-------------|----------------|
| **Members** | User profiles and management | 4 endpoints |
| **Activity** | Social activity streams | 4 endpoints |
| **Groups** | User groups and communities | 5 endpoints |
| **Messages** | Private messaging | 3 endpoints |
| **Notifications** | User notifications | 3 endpoints |
| **Friends** | Friendship management | 5 endpoints |
| **Achievements** | Gamification system | 10 endpoints |
| **Mentions** | User mention system | 7 endpoints |
| **Books & Library** | Book management & tracking | 9 endpoints |
| **User Moderation** | Block, mute, report | 7 endpoints |
| **ISBN Management** | Book ISBN operations | 4 endpoints |
| **User Stats** | Reading statistics | 1 endpoint |
| **Signup** | User registration | 4 endpoints |

**Total: 66+ endpoints**

---

## Core Endpoints

These endpoints provide optimized versions of BuddyPress functionality with GRead-specific enhancements.

## Members Endpoints

**Base:** `/gread/v1/members`

### List Members

🌐 **Public**

Retrieve a list of community members.

**Endpoint:** `GET /gread/v1/members`

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/members"
```

### Get Member

🌐 **Public**

Retrieve a specific member's profile.

**Endpoint:** `GET /gread/v1/members/{id}`

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/members/4"
```

### Update Member

🔒 **Protected**

Update member information.

**Endpoint:** `PUT /gread/v1/members/{id}`

**Example Request:**
```bash
curl -X PUT "https://gread.fun/wp-json/gread/v1/members/4" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Name"
  }'
```

### Get Member XProfile

🌐 **Public** (visibility rules apply)

Retrieve extended profile data.

**Endpoint:** `GET /gread/v1/members/{id}/xprofile`

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/members/4/xprofile"
```

### Update Member XProfile

🔒 **Protected**

Update extended profile data.

**Endpoint:** `PUT /gread/v1/members/{id}/xprofile`

**Example Request:**
```bash
curl -X PUT "https://gread.fun/wp-json/gread/v1/members/4/xprofile" \
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

## Activity Endpoints

**Base:** `/gread/v1/activity`

### List Activities

🌐 **Public**

Retrieve activity stream with GRead enhancements (book mentions parsed).

**Endpoint:** `GET /gread/v1/activity`

**Parameters:**
- `per_page` (integer) - Items per page (default: 20)
- `page` (integer) - Page number (default: 1)

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/activity?per_page=5"
```

**Example Response:**
```json
{
  "activities": [
    {
      "id": 344,
      "user_id": 4,
      "component": "activity",
      "type": "activity_update",
      "action": "<a href=\"https://gread.fun/users/brycedyce/\">BryceDyce</a> posted an update",
      "content": "Also, started reading #[book-id-2770:Babel : Or the Necessity of Violence] today...",
      "primary_link": "https://gread.fun/users/brycedyce/",
      "date_recorded": "2025-11-17 22:19:13",
      "display_name": "BryceDyce",
      "user_fullname": "BryceDyce"
    }
  ],
  "total": 120,
  "pages": 6
}
```

### Create Activity

🔒 **Protected**

Post a new activity update.

**Endpoint:** `POST /gread/v1/activity`

**Parameters:**
- `content` (string) - Activity content (required)
- `component` (string) - Component type (optional)
- `type` (string) - Activity type (optional)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/gread/v1/activity" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Just finished reading an amazing book! #[book-id-2768:Leviathan Wakes]"
  }'
```

### Delete Activity

🔒 **Protected**

Delete an activity item.

**Endpoint:** `DELETE /gread/v1/activity/{id}`

**Example Request:**
```bash
curl -X DELETE "https://gread.fun/wp-json/gread/v1/activity/345" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Favorite Activity

🔒 **Protected**

Toggle favorite status on an activity.

**Endpoint:** `POST /gread/v1/activity/{id}/favorite`

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/gread/v1/activity/345/favorite" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Add Activity Comment

🔒 **Protected**

Add a comment to an activity.

**Endpoint:** `POST /gread/v1/activity/{id}/comment`

**Parameters:**
- `content` (string) - Comment content (required)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/gread/v1/activity/345/comment" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Great book! I loved it too."
  }'
```

---

## Groups Endpoints

**Base:** `/gread/v1/groups`

### List Groups

🌐 **Public**

**Endpoint:** `GET /gread/v1/groups`

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/groups"
```

### Get Group

🌐 **Public**

**Endpoint:** `GET /gread/v1/groups/{id}`

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/groups/1"
```

### Create Group

🔒 **Protected**

**Endpoint:** `POST /gread/v1/groups`

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/gread/v1/groups" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Sci-Fi Book Club",
    "description": "For lovers of science fiction",
    "status": "public"
  }'
```

### Update Group

🔒 **Protected**

**Endpoint:** `PUT /gread/v1/groups/{id}`

### Delete Group

🔒 **Protected**

**Endpoint:** `DELETE /gread/v1/groups/{id}`

### List Group Members

🌐 **Public**

**Endpoint:** `GET /gread/v1/groups/{id}/members`

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/groups/1/members"
```

### Add Group Member

🔒 **Protected**

**Endpoint:** `POST /gread/v1/groups/{id}/members/{user_id}`

### Remove Group Member

🔒 **Protected**

**Endpoint:** `DELETE /gread/v1/groups/{id}/members/{user_id}`

---

## Messages Endpoints

**Base:** `/gread/v1/messages`

### List Messages

🔒 **Protected**

**Endpoint:** `GET /gread/v1/messages`

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/messages" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Get Message Thread

🔒 **Protected**

**Endpoint:** `GET /gread/v1/messages/{id}`

### Send Message

🔒 **Protected**

**Endpoint:** `POST /gread/v1/messages`

**Parameters:**
- `recipients` (array) - Recipient user IDs (required for new thread)
- `subject` (string) - Message subject (required for new thread)
- `message` (string) - Message content (required)
- `id` (integer) - Thread ID (for replies)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/gread/v1/messages" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "recipients": [5],
    "subject": "Book Recommendation",
    "message": "Have you read Leviathan Wakes?"
  }'
```

### Delete Message Thread

🔒 **Protected**

**Endpoint:** `DELETE /gread/v1/messages/{id}`

---

## Notifications Endpoints

**Base:** `/gread/v1/notifications`

### List Notifications

🔒 **Protected**

**Endpoint:** `GET /gread/v1/notifications`

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/notifications" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Update Notification

🔒 **Protected**

Mark notification as read/unread.

**Endpoint:** `PUT /gread/v1/notifications/{id}`

**Parameters:**
- `is_new` (boolean) - true for unread, false for read

**Example Request:**
```bash
curl -X PUT "https://gread.fun/wp-json/gread/v1/notifications/123" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "is_new": false
  }'
```

### Delete Notification

🔒 **Protected**

**Endpoint:** `DELETE /gread/v1/notifications/{id}`

---

## Friends Endpoints

**Base:** `/gread/v1/friends`

### Get User's Friends

🌐 **Public**

**Endpoint:** `GET /gread/v1/friends/{user_id}`

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/friends/4"
```

### Send Friend Request

🔒 **Protected**

**Endpoint:** `POST /gread/v1/friends/request`

**Parameters:**
- `friend_id` (integer) - User ID to send request to (required)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/gread/v1/friends/request" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "friend_id": 8
  }'
```

### Accept Friend Request

🔒 **Protected**

**Endpoint:** `POST /gread/v1/friends/{id}/accept`

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/gread/v1/friends/42/accept" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Reject Friend Request

🔒 **Protected**

**Endpoint:** `POST /gread/v1/friends/{id}/reject`

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/gread/v1/friends/42/reject" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Remove Friend

🔒 **Protected**

**Endpoint:** `DELETE /gread/v1/friends/{user_id}/{friend_id}`

**Example Request:**
```bash
curl -X DELETE "https://gread.fun/wp-json/gread/v1/friends/4/8" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## GRead-Specific Features

## Achievements System

The achievements system provides gamification with badges, points, and leaderboards.

**Base:** `/gread/v1/achievements`

### List All Achievements

🌐 **Public**

Retrieve all available achievements.

**Endpoint:** `GET /gread/v1/achievements`

**Parameters:**
- `show_hidden` (boolean) - Include hidden achievements (default: false)

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/achievements"
```

**Example Response:**
```json
[
  {
    "id": 1,
    "slug": "literate",
    "name": "Literate",
    "description": "Read 100 pages.",
    "icon": {
      "type": "star",
      "color": "#ffd700",
      "symbol": "⭐"
    },
    "unlock_requirements": {
      "metric": "pages_read",
      "value": 100,
      "condition": "simple"
    },
    "reward": 50,
    "is_hidden": false,
    "display_order": 0
  },
  {
    "id": 6,
    "slug": "amateur-librarian",
    "name": "Amateur Librarian",
    "description": "Added 10 books to the database.",
    "icon": {
      "type": "book",
      "color": "#ffd700",
      "symbol": "📚"
    },
    "unlock_requirements": {
      "metric": "books_added",
      "value": 10,
      "condition": "simple"
    },
    "reward": 125,
    "is_hidden": false
  }
]
```

### Get Single Achievement

🌐 **Public**

**Endpoint:** `GET /gread/v1/achievements/{id}`

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/achievements/1"
```

### Get Achievement by Slug

🌐 **Public**

**Endpoint:** `GET /gread/v1/achievements/slug/{slug}`

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/achievements/slug/literate"
```

### Get User Achievements

🌐 **Public**

Retrieve achievements for a specific user.

**Endpoint:** `GET /gread/v1/user/{id}/achievements`

**Parameters:**
- `filter` (string) - Filter: `all`, `unlocked`, `locked` (default: all)

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/user/4/achievements?filter=unlocked"
```

### Get My Achievements

🔒 **Protected**

Retrieve achievements for the authenticated user.

**Endpoint:** `GET /gread/v1/me/achievements`

**Parameters:**
- `filter` (string) - Filter: `all`, `unlocked`, `locked` (default: all)

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/me/achievements?filter=all" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Check Achievements

🔒 **Protected**

Trigger achievement check for the authenticated user. This checks if any new achievements have been unlocked based on current progress.

**Endpoint:** `POST /gread/v1/me/achievements/check`

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/gread/v1/me/achievements/check" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Example Response:**
```json
{
  "newly_unlocked": [
    {
      "id": 4,
      "slug": "ill-raise-you",
      "name": "I'll Raise You!",
      "description": "Read 1,000 pages.",
      "reward": 100
    }
  ],
  "total_unlocked": 5,
  "total_points": 450
}
```

### Get Achievement Statistics

🌐 **Public**

Get global achievement statistics.

**Endpoint:** `GET /gread/v1/achievements/stats`

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/achievements/stats"
```

**Example Response:**
```json
{
  "total_achievements": 11,
  "total_unlocks": 31,
  "average_unlocks_per_achievement": 2.82,
  "most_unlocked": {
    "id": 1,
    "name": "Literate",
    "slug": "literate",
    "unlock_count": 6
  },
  "least_unlocked": {
    "id": 9,
    "name": "Master Librarian",
    "slug": "master-librarian",
    "unlock_count": 0
  },
  "top_achievers": [
    {
      "user_id": "2",
      "user_name": "daniel",
      "achievement_count": 9
    },
    {
      "user_id": "4",
      "user_name": "BryceDyce",
      "achievement_count": 9
    }
  ]
}
```

### Get Achievement Leaderboard

🌐 **Public**

Get the global achievement leaderboard.

**Endpoint:** `GET /gread/v1/achievements/leaderboard`

**Parameters:**
- `limit` (integer) - Number of users to return (default: 10)
- `offset` (integer) - Pagination offset (default: 0)

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/achievements/leaderboard?limit=5"
```

**Example Response:**
```json
[
  {
    "rank": 1,
    "user_id": "2",
    "user_name": "daniel",
    "user_avatar_url": "https://gread.fun/wp-content/uploads/avatars/2/1760138793-bpfull.png",
    "achievement_count": 9
  },
  {
    "rank": 2,
    "user_id": "4",
    "user_name": "BryceDyce",
    "user_avatar_url": "https://gread.fun/wp-content/uploads/avatars/4/1760913305-bpfull.jpg",
    "achievement_count": 9
  },
  {
    "rank": 3,
    "user_id": "3",
    "user_name": "madwickeddonkey",
    "user_avatar_url": "https://gread.fun/wp-content/uploads/avatars/3/1759781525-bpfull.png",
    "achievement_count": 4
  }
]
```

---

## Mentions System

Enhanced user mention functionality for tagging users in content.

**Base:** `/gread/v1/mentions`

### Search Users for Mentions

🌐 **Public**

Search users by username for mentions/tagging.

**Endpoint:** `GET /gread/v1/mentions/search`

**Parameters:**
- `query` (string) - Search query (required)
- `limit` (integer) - Max results (default: 10)

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/mentions/search?query=daniel&limit=5"
```

**Example Response:**
```json
{
  "query": "daniel",
  "total": 2,
  "users": [
    {
      "id": 2,
      "username": "daniel",
      "display_name": "daniel",
      "email": "user@example.com",
      "avatar_url": "https://gread.fun/wp-content/uploads/avatars/2/1760138793-bpfull.png",
      "profile_url": "https://gread.fun/users/daniel/",
      "mention_text": "@daniel"
    },
    {
      "id": 8,
      "username": "notdaniel",
      "display_name": "notdaniel",
      "email": "user2@example.com",
      "avatar_url": "https://gread.fun/wp-content/uploads/avatars/8/1760387968-bpfull.jpg",
      "profile_url": "https://gread.fun/users/notdaniel/",
      "mention_text": "@notdaniel"
    }
  ]
}
```

### Get User by ID (for mentions)

🌐 **Public**

Get user mention data by ID.

**Endpoint:** `GET /gread/v1/mentions/user/{id}`

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/mentions/user/4"
```

### List All Mentionable Users

🌐 **Public**

Get a list of all users that can be mentioned.

**Endpoint:** `GET /gread/v1/mentions/users`

**Parameters:**
- `limit` (integer) - Max results (default: 50)
- `offset` (integer) - Pagination offset (default: 0)

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/mentions/users?limit=10"
```

**Example Response:**
```json
{
  "total": 24,
  "limit": 10,
  "offset": 0,
  "users": [
    {
      "id": 1,
      "username": "admin",
      "display_name": "admin",
      "avatar_url": "https://gread.fun/wp-content/uploads/avatars/1/...",
      "profile_url": "https://gread.fun/users/admin/",
      "mention_text": "@admin"
    }
  ]
}
```

### Get My Mentions

🔒 **Protected**

Get mentions of the authenticated user.

**Endpoint:** `GET /gread/v1/me/mentions`

**Parameters:**
- `limit` (integer) - Max results (default: 20)
- `offset` (integer) - Pagination offset (default: 0)
- `unread_only` (boolean) - Only unread mentions (default: false)

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/me/mentions?unread_only=true" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Get User Mentions

🌐 **Public**

Get mentions for a specific user.

**Endpoint:** `GET /gread/v1/user/{id}/mentions`

**Parameters:**
- `limit` (integer) - Max results (default: 20)
- `offset` (integer) - Pagination offset (default: 0)

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/user/4/mentions?limit=10"
```

### Get Activity with Mentions

🌐 **Public**

Get activities that contain user mentions.

**Endpoint:** `GET /gread/v1/mentions/activity`

**Parameters:**
- `user_id` (integer) - Filter by mentioned user (optional)
- `limit` (integer) - Max results (default: 20)
- `offset` (integer) - Pagination offset (default: 0)

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/mentions/activity?user_id=4&limit=10"
```

### Mark Mentions as Read

🔒 **Protected**

Mark all mentions for the authenticated user as read.

**Endpoint:** `POST /gread/v1/me/mentions/read`

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/gread/v1/me/mentions/read" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Books & Library System

Comprehensive book management, ISBN lookup, and personal library tracking.

**Base:** `/gread/v1/books` and `/gread/v1/library`

### Search Books

🌐 **Public**

Search for books in the GRead database.

**Endpoint:** `GET /gread/v1/books/search`

**Parameters:**
- `query` (string) - Search term (required)

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/books/search?query=leviathan"
```

**Example Response:**
```json
[
  {
    "id": 2768,
    "title": "Leviathan Wakes",
    "author": "James S. A. Corey",
    "isbn": "9780316129084",
    "page_count": 577,
    "content": "No description available.",
    "permalink": "https://gread.fun/books/9780316129084/"
  },
  {
    "id": 2335,
    "title": "Leviathan",
    "author": "Thomas Hobbes",
    "isbn": "9780141395098",
    "page_count": 688,
    "content": "No description available.",
    "permalink": "https://gread.fun/books/9780141395098/"
  }
]
```

### Get Book by ID

🌐 **Public**

Retrieve detailed book information.

**Endpoint:** `GET /gread/v1/book/{id}`

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/book/2768"
```

**Example Response:**
```json
{
  "id": 2768,
  "title": "Leviathan Wakes",
  "author": "James S. A. Corey",
  "description": "No description available.",
  "isbn": "9780316129084",
  "page_count": 577,
  "publication_year": "2011",
  "cover_image": "https://gread.fun/wp-content/uploads/2025/11/11295081-L.jpg",
  "statistics": {
    "total_readers": 0,
    "average_rating": 0,
    "review_count": 0
  }
}
```

### Lookup Book by ISBN

🌐 **Public**

Find a book by its ISBN number.

**Endpoint:** `GET /gread/v1/books/isbn`

**Parameters:**
- `isbn` (string) - ISBN number (required)

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/books/isbn?isbn=9780316129084"
```

### Get My Library

🔒 **Protected**

Retrieve the authenticated user's personal library.

**Endpoint:** `GET /gread/v1/library`

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/library" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Example Response:**
```json
{
  "user_id": 4,
  "books": [
    {
      "book_id": 2768,
      "title": "Leviathan Wakes",
      "author": "James S. A. Corey",
      "isbn": "9780316129084",
      "page_count": 577,
      "current_page": 250,
      "progress_percentage": 43.3,
      "status": "reading",
      "added_date": "2025-11-15T10:30:00",
      "last_updated": "2025-11-17T14:20:00"
    }
  ],
  "total_books": 12,
  "reading": 3,
  "completed": 8,
  "want_to_read": 1
}
```

### Add Book to Library

🔒 **Protected**

Add a book to the authenticated user's library.

**Endpoint:** `POST /gread/v1/library/add`

**Parameters:**
- `book_id` (integer) - Book ID to add (required)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/gread/v1/library/add" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "book_id": 2768
  }'
```

**Example Response:**
```json
{
  "success": true,
  "message": "Book added to library",
  "book_id": 2768,
  "library_entry": {
    "book_id": 2768,
    "current_page": 0,
    "status": "want_to_read",
    "added_date": "2025-11-18T12:00:00"
  }
}
```

### Update Reading Progress

🔒 **Protected**

Update the current page for a book in the library.

**Endpoint:** `POST /gread/v1/library/progress`

**Parameters:**
- `book_id` (integer) - Book ID (required)
- `current_page` (integer) - Current page number (required)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/gread/v1/library/progress" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "book_id": 2768,
    "current_page": 350
  }'
```

**Example Response:**
```json
{
  "success": true,
  "message": "Progress updated",
  "book_id": 2768,
  "current_page": 350,
  "total_pages": 577,
  "progress_percentage": 60.7,
  "pages_remaining": 227
}
```

### Remove Book from Library

🔒 **Protected**

Remove a book from the library.

**Endpoint:** `DELETE /gread/v1/library/remove`

**Parameters:**
- `book_id` (integer) - Book ID to remove (required)

**Example Request:**
```bash
curl -X DELETE "https://gread.fun/wp-json/gread/v1/library/remove?book_id=2768" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## User Moderation System

Block, mute, and report functionality for user moderation.

**Base:** `/gread/v1/user`

### Block User

🔒 **Protected**

Block a user to prevent interaction.

**Endpoint:** `POST /gread/v1/user/block`

**Parameters:**
- `user_id` (integer) - User ID to block (required)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/gread/v1/user/block" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 18
  }'
```

**Example Response:**
```json
{
  "success": true,
  "message": "User blocked successfully",
  "blocked_user_id": 18
}
```

### Unblock User

🔒 **Protected**

Unblock a previously blocked user.

**Endpoint:** `POST /gread/v1/user/unblock`

**Parameters:**
- `user_id` (integer) - User ID to unblock (required)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/gread/v1/user/unblock" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 18
  }'
```

### Mute User

🔒 **Protected**

Mute a user to hide their content without blocking.

**Endpoint:** `POST /gread/v1/user/mute`

**Parameters:**
- `user_id` (integer) - User ID to mute (required)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/gread/v1/user/mute" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 18
  }'
```

### Unmute User

🔒 **Protected**

Unmute a previously muted user.

**Endpoint:** `POST /gread/v1/user/unmute`

**Parameters:**
- `user_id` (integer) - User ID to unmute (required)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/gread/v1/user/unmute" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 18
  }'
```

### Report User

🔒 **Protected**

Report a user for inappropriate behavior.

**Endpoint:** `POST /gread/v1/user/report`

**Parameters:**
- `user_id` (integer) - User ID to report (required)
- `reason` (string) - Reason for report (required)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/gread/v1/user/report" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 18,
    "reason": "Spam or inappropriate content"
  }'
```

**Example Response:**
```json
{
  "success": true,
  "message": "User reported successfully",
  "report_id": 42,
  "status": "pending_review"
}
```

### Get Blocked Users List

🔒 **Protected**

Retrieve list of blocked users for the authenticated user.

**Endpoint:** `GET /gread/v1/user/blocked_list`

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/user/blocked_list" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Example Response:**
```json
{
  "blocked_users": [
    {
      "user_id": 18,
      "username": "blockme",
      "display_name": "Block Me",
      "blocked_date": "2025-11-10T09:15:00"
    }
  ],
  "total": 1
}
```

### Get Muted Users List

🔒 **Protected**

Retrieve list of muted users for the authenticated user.

**Endpoint:** `GET /gread/v1/user/muted_list`

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/user/muted_list" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## ISBN Management

Advanced ISBN management for books (requires appropriate permissions).

**Base:** `/gread/v1/books/{id}/isbns`

### Get Book ISBNs

🌐 **Public**

Get all ISBN numbers associated with a book.

**Endpoint:** `GET /gread/v1/books/{id}/isbns`

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/books/2768/isbns"
```

**Example Response:**
```json
{
  "book_id": 2768,
  "title": "Leviathan Wakes",
  "isbns": [
    {
      "isbn": "9780316129084",
      "edition": "Paperback",
      "publication_year": "2011",
      "is_primary": true
    },
    {
      "isbn": "9780316129077",
      "edition": "Hardcover",
      "publication_year": "2011",
      "is_primary": false
    }
  ]
}
```

### Add ISBN to Book

🔒 **Protected** (requires permissions)

Add an ISBN to a book.

**Endpoint:** `POST /gread/v1/books/{id}/isbns`

**Parameters:**
- `isbn` (string) - ISBN number (required)
- `edition` (string) - Edition name (optional)
- `publication_year` (integer) - Publication year (optional)
- `is_primary` (boolean) - Set as primary ISBN (default: false)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/gread/v1/books/2768/isbns" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "isbn": "9780316129077",
    "edition": "Hardcover",
    "publication_year": 2011,
    "is_primary": false
  }'
```

### Delete ISBN

🔒 **Protected** (requires permissions)

Remove an ISBN from the database.

**Endpoint:** `DELETE /gread/v1/books/isbn/{isbn}`

**Example Request:**
```bash
curl -X DELETE "https://gread.fun/wp-json/gread/v1/books/isbn/9780316129077" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Set Primary ISBN

🔒 **Protected** (requires permissions)

Set which ISBN is the primary one for a book.

**Endpoint:** `PUT /gread/v1/books/{id}/isbns/primary`

**Parameters:**
- `isbn` (string) - ISBN to set as primary (required)

**Example Request:**
```bash
curl -X PUT "https://gread.fun/wp-json/gread/v1/books/2768/isbns/primary" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "isbn": "9780316129084"
  }'
```

---

## User Statistics

**Base:** `/gread/v1/user/{id}/stats`

### Get User Reading Statistics

🔒 **Protected** (own stats) / 🌐 **Public** (others)

Retrieve comprehensive reading statistics for a user.

**Endpoint:** `GET /gread/v1/user/{id}/stats`

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/user/4/stats"
```

**Example Response:**
```json
{
  "user_id": 4,
  "username": "BryceDyce",
  "statistics": {
    "books_read": 42,
    "pages_read": 15234,
    "books_in_library": 67,
    "currently_reading": 3,
    "books_added_to_db": 15,
    "average_pages_per_book": 363,
    "reading_streak_days": 12,
    "achievements_unlocked": 9,
    "total_achievement_points": 650,
    "member_since": "2025-09-22",
    "last_activity": "2025-11-17T22:19:13"
  },
  "favorite_genres": [
    {
      "genre": "Science Fiction",
      "count": 18
    },
    {
      "genre": "Fantasy",
      "count": 12
    }
  ],
  "reading_activity": {
    "last_30_days": {
      "books_completed": 3,
      "pages_read": 1247
    },
    "this_year": {
      "books_completed": 28,
      "pages_read": 10567
    }
  }
}
```

---

## Signup Endpoints

Custom signup endpoints with enhanced validation and XProfile integration.

**Base:** `/gread/v1/signup`

### List Signups

👑 **Admin**

List pending signups (admin only).

**Endpoint:** `GET /gread/v1/signup`

**Parameters:**
- `number` (integer) - Number of signups (default: 10)
- `offset` (integer) - Pagination offset (default: 0)
- `orderby` (string) - Order by: `signup_id`, `login`, `email`, `registered`, `activated` (default: signup_id)
- `order` (string) - Sort order: `asc` or `desc` (default: desc)
- `user_login` (string) - Filter by specific username

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/signup?number=20" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Get Signup

👑 **Admin**

Get a specific signup by ID, email, or activation key.

**Endpoint:** `GET /gread/v1/signup/{id}`

**Example Request:**
```bash
curl -X GET "https://gread.fun/wp-json/gread/v1/signup/45" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Create Signup

🌐 **Public** (if registration enabled)

Register a new user account.

**Endpoint:** `POST /gread/v1/signup`

**Parameters:**
- `user_login` (string) - Username (required)
- `user_email` (string) - Email address (required)
- `password` (string) - Password (required)
- `signup_field_data` (array) - XProfile field data (required)

**Example Request:**
```bash
curl -X POST "https://gread.fun/wp-json/gread/v1/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "user_login": "newreader",
    "user_email": "newreader@example.com",
    "password": "SecurePass123!",
    "signup_field_data": [
      {
        "field_id": 1,
        "value": "New Reader",
        "visibility": "public"
      }
    ]
  }'
```

**Example Response:**
```json
{
  "success": true,
  "signup_id": 46,
  "user_login": "newreader",
  "user_email": "newreader@example.com",
  "activation_key": "abc123def456",
  "message": "Account created. Please check your email for activation instructions."
}
```

### Delete Signup

👑 **Admin**

Delete a pending signup.

**Endpoint:** `DELETE /gread/v1/signup/{id}`

**Example Request:**
```bash
curl -X DELETE "https://gread.fun/wp-json/gread/v1/signup/46" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

## Error Handling

The GRead API uses standard HTTP status codes and returns detailed error information.

### HTTP Status Codes

- `200 OK` - Successful GET/PUT request
- `201 Created` - Successful POST request
- `204 No Content` - Successful DELETE request
- `400 Bad Request` - Invalid parameters
- `401 Unauthorized` - Authentication required/failed
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

| Code | Meaning |
|------|---------|
| `rest_forbidden` | Insufficient permissions |
| `rest_invalid_param` | Invalid parameter value |
| `rest_missing_callback_param` | Missing required parameter |
| `rest_no_route` | Endpoint not found |
| `gread_invalid_isbn` | Invalid ISBN format |
| `gread_book_not_found` | Book not found in database |
| `gread_already_in_library` | Book already in user's library |
| `gread_user_blocked` | Cannot interact with blocked user |

### Example Error Handling

```bash
# Bash example with error handling
response=$(curl -s -w "\n%{http_code}" \
  "https://gread.fun/wp-json/gread/v1/library/add" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"book_id": 2768}')

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 201 ]; then
  echo "Success: $body"
else
  echo "Error (HTTP $http_code): $body"
fi
```

---

## Rate Limiting

### Best Practices

1. **Implement Exponential Backoff**
   - Start with 1 second delay
   - Double delay after each failure
   - Max delay of 60 seconds

2. **Cache Responses**
   - Cache public data (achievements, book info)
   - Respect cache headers

3. **Batch Requests**
   - Use WordPress batch API when possible
   - Combine multiple operations

4. **Use Webhooks**
   - Subscribe to events instead of polling
   - Check with GRead admins for availability

### Recommended Limits

- **Anonymous users:** 60 requests/minute
- **Authenticated users:** 120 requests/minute
- **Premium users:** 300 requests/minute (if applicable)

**Note:** These are recommended guidelines. Check with site administrators for actual limits.

---

## Pagination Patterns

Most collection endpoints support pagination:

```bash
# First page (default)
curl "https://gread.fun/wp-json/gread/v1/achievements"

# Specific page
curl "https://gread.fun/wp-json/gread/v1/achievements/leaderboard?limit=20&offset=20"

# Using limit/offset
curl "https://gread.fun/wp-json/gread/v1/mentions/users?limit=50&offset=100"
```

---

## Advanced Examples

### Complete Reading Flow

```bash
# 1. Search for a book
curl "https://gread.fun/wp-json/gread/v1/books/search?query=leviathan"

# 2. Add to library
curl -X POST "https://gread.fun/wp-json/gread/v1/library/add" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"book_id": 2768}'

# 3. Update progress as you read
curl -X POST "https://gread.fun/wp-json/gread/v1/library/progress" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"book_id": 2768, "current_page": 100}'

# 4. Post activity about the book
curl -X POST "https://gread.fun/wp-json/gread/v1/activity" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"content": "Loving #[book-id-2768:Leviathan Wakes] so far! @daniel you should read this."}'

# 5. Check for new achievements
curl -X POST "https://gread.fun/wp-json/gread/v1/me/achievements/check" \
  -H "Authorization: Bearer $TOKEN"
```

### Social Interaction Flow

```bash
# 1. Search for users to mention
curl "https://gread.fun/wp-json/gread/v1/mentions/search?query=daniel"

# 2. Get user's reading stats
curl "https://gread.fun/wp-json/gread/v1/user/4/stats"

# 3. Send friend request
curl -X POST "https://gread.fun/wp-json/gread/v1/friends/request" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"friend_id": 4}'

# 4. Check notifications
curl "https://gread.fun/wp-json/gread/v1/notifications" \
  -H "Authorization: Bearer $TOKEN"

# 5. View achievement leaderboard
curl "https://gread.fun/wp-json/gread/v1/achievements/leaderboard?limit=10"
```

---

## SDK Examples

### JavaScript/Node.js

```javascript
class GReadAPI {
  constructor(token) {
    this.baseURL = 'https://gread.fun/wp-json/gread/v1';
    this.token = token;
  }

  async request(endpoint, method = 'GET', data = null) {
    const options = {
      method,
      headers: {
        'Content-Type': 'application/json',
        ...(this.token && { 'Authorization': `Bearer ${this.token}` })
      }
    };

    if (data && method !== 'GET') {
      options.body = JSON.stringify(data);
    }

    const response = await fetch(`${this.baseURL}${endpoint}`, options);
    return response.json();
  }

  // Books
  async searchBooks(query) {
    return this.request(`/books/search?query=${encodeURIComponent(query)}`);
  }

  async getBook(id) {
    return this.request(`/book/${id}`);
  }

  // Library
  async getMyLibrary() {
    return this.request('/library');
  }

  async addToLibrary(bookId) {
    return this.request('/library/add', 'POST', { book_id: bookId });
  }

  async updateProgress(bookId, currentPage) {
    return this.request('/library/progress', 'POST', {
      book_id: bookId,
      current_page: currentPage
    });
  }

  // Achievements
  async getAchievements() {
    return this.request('/achievements');
  }

  async getMyAchievements(filter = 'all') {
    return this.request(`/me/achievements?filter=${filter}`);
  }

  async checkAchievements() {
    return this.request('/me/achievements/check', 'POST');
  }

  async getLeaderboard(limit = 10) {
    return this.request(`/achievements/leaderboard?limit=${limit}`);
  }

  // Activity
  async getActivity(perPage = 20, page = 1) {
    return this.request(`/activity?per_page=${perPage}&page=${page}`);
  }

  async postActivity(content) {
    return this.request('/activity', 'POST', { content });
  }

  // Mentions
  async searchUsers(query, limit = 10) {
    return this.request(`/mentions/search?query=${encodeURIComponent(query)}&limit=${limit}`);
  }

  async getMyMentions(unreadOnly = false) {
    return this.request(`/me/mentions?unread_only=${unreadOnly}`);
  }

  // User Stats
  async getUserStats(userId) {
    return this.request(`/user/${userId}/stats`);
  }
}

// Usage
const api = new GReadAPI('your_jwt_token_here');

// Search and add a book
const books = await api.searchBooks('leviathan');
await api.addToLibrary(books[0].id);

// Check achievements
const newAchievements = await api.checkAchievements();
console.log('New achievements:', newAchievements.newly_unlocked);
```

### Python

```python
import requests

class GReadAPI:
    def __init__(self, token=None):
        self.base_url = 'https://gread.fun/wp-json/gread/v1'
        self.token = token
        self.session = requests.Session()
        if token:
            self.session.headers.update({'Authorization': f'Bearer {token}'})

    def _request(self, endpoint, method='GET', data=None):
        url = f'{self.base_url}{endpoint}'
        response = self.session.request(method, url, json=data)
        response.raise_for_status()
        return response.json()

    # Books
    def search_books(self, query):
        return self._request(f'/books/search?query={query}')

    def get_book(self, book_id):
        return self._request(f'/book/{book_id}')

    # Library
    def get_my_library(self):
        return self._request('/library')

    def add_to_library(self, book_id):
        return self._request('/library/add', 'POST', {'book_id': book_id})

    def update_progress(self, book_id, current_page):
        return self._request('/library/progress', 'POST', {
            'book_id': book_id,
            'current_page': current_page
        })

    # Achievements
    def get_achievements(self, show_hidden=False):
        return self._request(f'/achievements?show_hidden={show_hidden}')

    def get_my_achievements(self, filter_type='all'):
        return self._request(f'/me/achievements?filter={filter_type}')

    def check_achievements(self):
        return self._request('/me/achievements/check', 'POST')

    def get_leaderboard(self, limit=10, offset=0):
        return self._request(f'/achievements/leaderboard?limit={limit}&offset={offset}')

    # Activity
    def get_activity(self, per_page=20, page=1):
        return self._request(f'/activity?per_page={per_page}&page={page}')

    def post_activity(self, content):
        return self._request('/activity', 'POST', {'content': content})

    # User Stats
    def get_user_stats(self, user_id):
        return self._request(f'/user/{user_id}/stats')

# Usage
api = GReadAPI('your_jwt_token_here')

# Search and add book
books = api.search_books('leviathan')
api.add_to_library(books[0]['id'])

# Update reading progress
api.update_progress(books[0]['id'], 100)

# Check for new achievements
result = api.check_achievements()
print(f"Newly unlocked: {result['newly_unlocked']}")
```

---

## Webhooks (Future Feature)

**Note:** Webhooks are not currently implemented but may be available in future versions.

Potential webhook events:
- `achievement.unlocked` - User unlocks an achievement
- `book.added` - Book added to library
- `book.completed` - User finishes reading a book
- `friend.request` - Friend request received
- `mention.received` - User mentioned in content
- `message.received` - New private message

---

## Support and Resources

- **API Documentation:** This guide
- **BuddyPress API Guide:** See `BUDDYPRESS_API_GUIDE.md` for underlying BuddyPress endpoints
- **GRead Website:** https://gread.fun
- **Report Issues:** Contact site administrators

---

## Changelog

### Version 1.0 (November 2025)

**Initial Release**
- Complete GRead Custom API documentation
- Achievements system with leaderboards
- Mentions system for user tagging
- Books & Library management
- User moderation (block, mute, report)
- ISBN management
- User statistics
- Enhanced BuddyPress endpoint wrappers
- Real-world examples for all endpoints

---

## Contributing

To request new features or report bugs with the GRead API:

1. Test your use case thoroughly
2. Provide clear examples
3. Contact the GRead development team
4. Include API version and endpoint details

---

## License

This API is proprietary to GRead.fun. Unauthorized use is prohibited.

---

*This guide was created for the GRead Custom REST API at gread.fun. Last updated: November 18, 2025*
