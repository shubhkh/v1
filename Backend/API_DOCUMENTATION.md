# Concept360 Backend API Documentation

Base URL: `http://localhost:8002`

## Table of Contents
1. [Document Upload & Processing](#document-upload--processing)
2. [Content Generation](#content-generation)
3. [Metadata APIs](#metadata-apis)
4. [Chapter & Subchapter APIs](#chapter--subchapter-apis)
5. [Content Retrieval APIs](#content-retrieval-apis)
6. [Chat API](#chat-api)
7. [Statistics](#statistics)

---

## Document Upload & Processing

### Upload PDF Document
**POST** `/`

Upload a PDF document for processing.

**Request:**
```json
Content-Type: multipart/form-data

{
  "file": <PDF file>,
  "board": "CBSE",
  "class": "9",
  "subject": "MATHS"
}
```

**Response:**
```json
{
  "task_id": "uuid-here",
  "message": "Task started successfully",
  "status_url": "/api/task-status/{task_id}/",
  "websocket_url": "ws://localhost:8002/ws/task/{task_id}/"
}
```

### Check Upload Status
**GET** `/task-status/{task_id}/`

Get the status of a PDF processing task.

**Response:**
```json
{
  "status": "completed",
  "progress": 100,
  "message": "Pipeline completed successfully"
}
```

---

## Content Generation

### Generate Educational Content
**POST** `/api/content/generate/`

Generate notes, MCQs, subjective questions, and flashcards for a subchapter.

**Request:**
```json
{
  "board": "CBSE",
  "class": "9",
  "subject": "MATHS",
  "chapter": "4 - LINEAR EQUATIONS IN TWO VARIABLES",
  "subchapter": "4.1 Introduction",
  "num_mcqs": 10,
  "num_subjective": 5,
  "num_flashcards": 10,
  "force": false
}
```

**Parameters:**
- `force` (optional): If `true`, regenerate content even if already processed

**Response:**
```json
{
  "task_id": "uuid-here",
  "message": "Content generation started",
  "status_url": "/api/content/status/{task_id}/"
}
```

### Check Generation Status
**GET** `/api/content/status/{task_id}/`

**Response:**
```json
{
  "status": "completed",
  "message": "Content generated successfully",
  "data": {
    "success": true,
    "notes_file_path": "/path/to/notes.md",
    "num_mcqs_created": 10,
    "num_subjective_created": 5,
    "num_flashcards_created": 10
  }
}
```

---

## Metadata APIs

### Get All Boards
**GET** `/api/content/boards/`

**Response:**
```json
[
  {
    "id": 1,
    "name": "CBSE"
  },
  {
    "id": 2,
    "name": "ICSE"
  }
]
```

### Get All Classes
**GET** `/api/content/classes/`

**Response:**
```json
[
  {
    "id": 1,
    "standard": "8"
  },
  {
    "id": 2,
    "standard": "9"
  }
]
```

### Get All Subjects
**GET** `/api/content/subjects/`

**Response:**
```json
[
  {
    "id": 1,
    "subject": "MATHS"
  },
  {
    "id": 2,
    "subject": "SCIENCE"
  }
]
```

---

## Chapter & Subchapter APIs

### Get Chapters
**GET** `/api/content/chapters/?board=CBSE&class=9&subject=MATHS`

Get all chapters for a specific board, class, and subject.

**Query Parameters:**
- `board` (required): Board name
- `class` (required): Class/standard
- `subject` (required): Subject name

**Response:**
```json
[
  {
    "chapter_id": 1,
    "board": {
      "id": 1,
      "name": "CBSE"
    },
    "class_field": {
      "id": 1,
      "standard": "9"
    },
    "subject": {
      "id": 1,
      "subject": "MATHS"
    },
    "chapter_name": "4 - LINEAR EQUATIONS IN TWO VARIABLES",
    "chapter_file_path": "/path/to/chapter",
    "subchapters": [
      {
        "chapter_subchapter_id": 1,
        "subchapter_name": "4.1 Introduction",
        "subchapter_file_path": "/path/to/notes.pdf",
        "processed": true
      }
    ]
  }
]
```

### Get Subchapters for a Chapter
**GET** `/api/content/chapters/{chapter_id}/subchapters/`

**Response:**
```json
[
  {
    "chapter_subchapter_id": 1,
    "subchapter_name": "4.1 Introduction",
    "subchapter_file_path": "/path/to/notes.pdf",
    "processed": true
  },
  {
    "chapter_subchapter_id": 2,
    "subchapter_name": "4.2 Linear Equations",
    "subchapter_file_path": null,
    "processed": false
  }
]
```

### Get Subchapter Details
**GET** `/api/content/subchapters/{subchapter_id}/`

Get detailed information about a subchapter including content counts.

**Response:**
```json
{
  "subchapter": {
    "chapter_subchapter_id": 1,
    "subchapter_name": "4.1 Introduction",
    "subchapter_file_path": "/path/to/notes.pdf",
    "processed": true
  },
  "chapter_name": "4 - LINEAR EQUATIONS IN TWO VARIABLES",
  "board": "CBSE",
  "class": "9",
  "subject": "MATHS",
  "mcq_count": 10,
  "subjective_count": 5,
  "flashcard_count": 10,
  "has_notes": true,
  "notes_path": "/path/to/notes.pdf"
}
```

### Get Processed Subchapters
**GET** `/api/content/subchapters/processed/?board=CBSE&class=9&subject=MATHS`

Get all subchapters that have been processed (optional filters).

**Query Parameters (all optional):**
- `board`: Filter by board
- `class`: Filter by class
- `subject`: Filter by subject

**Response:**
```json
[
  {
    "id": 1,
    "name": "4.1 Introduction",
    "chapter": "4 - LINEAR EQUATIONS IN TWO VARIABLES",
    "board": "CBSE",
    "class": "9",
    "subject": "MATHS",
    "mcq_count": 10,
    "subjective_count": 5,
    "flashcard_count": 10,
    "has_notes": true
  }
]
```

---

## Content Retrieval APIs

### Get MCQs
**GET** `/api/content/subchapters/{subchapter_id}/mcqs/`

Get all MCQs for a subchapter.

**Response:**
```json
{
  "subchapter_name": "4.1 Introduction",
  "total_mcqs": 10,
  "mcqs": [
    {
      "id": 1,
      "question": "What is a linear equation in two variables?",
      "option_a": "An equation with one variable",
      "option_b": "An equation with two variables of degree 1",
      "option_c": "An equation with three variables",
      "option_d": "A quadratic equation",
      "correct_answer": "B"
    }
  ]
}
```

### Get Subjective Questions
**GET** `/api/content/subchapters/{subchapter_id}/subjective/`

**Response:**
```json
{
  "subchapter_name": "4.1 Introduction",
  "total_questions": 5,
  "questions": [
    {
      "id": 1,
      "question": "Explain the concept of linear equations in two variables.",
      "solution": "A linear equation in two variables is an equation that can be written in the form ax + by + c = 0..."
    }
  ]
}
```

### Get Flashcards
**GET** `/api/content/subchapters/{subchapter_id}/flashcards/`

**Response:**
```json
{
  "subchapter_name": "4.1 Introduction",
  "total_flashcards": 10,
  "flashcards": [
    {
      "id": 1,
      "front": "What is the general form of a linear equation in two variables?",
      "back": "ax + by + c = 0, where a, b, c are real numbers and a, b ≠ 0"
    }
  ]
}
```

### Get Notes
**GET** `/api/content/subchapters/{subchapter_id}/notes/`

Get notes content (markdown or PDF info).

**Response (Markdown):**
```json
{
  "subchapter_name": "4.1 Introduction",
  "file_type": "markdown",
  "content": "# 4.1 Introduction\n\n**Board:** CBSE...",
  "file_path": "/path/to/notes.md"
}
```

**Response (PDF):**
```json
{
  "subchapter_name": "4.1 Introduction",
  "file_type": "pdf",
  "file_path": "/path/to/notes.pdf",
  "download_url": "/api/content/subchapters/1/notes/download/"
}
```

### Download Notes PDF
**GET** `/api/content/subchapters/{subchapter_id}/notes/download/`

Downloads the PDF file.

**Response:** File download

---

## Chat API

### Send Chat Message
**POST** `/api/chat/chat/`

Send a chat message to the AI assistant.

**Request:**
```json
{
  "query": "What is a linear equation?",
  "board": "CBSE",
  "standard": "9",
  "collection_name": "concept360_v3",
  "k": 10,
  "image_path": null,
  "thread_id": "user_session_1"
}
```

**Response:**
```json
{
  "query": "What is a linear equation?",
  "response": {
    "success": true,
    "answer": "A linear equation is an equation in which...",
    "sources": 5,
    "context": [
      {
        "content": "...",
        "metadata": {
          "chapter": "4 - LINEAR EQUATIONS",
          "image_urls": ["https://..."]
        }
      }
    ]
  },
  "board": "CBSE",
  "standard": "9"
}
```

**Note:** The response may contain image URLs in the context metadata. Parse these to display images in your Angular UI.

### WebSocket Chat
**WS** `ws://localhost:8002/ws/chat/`

Connect to WebSocket for real-time chat.

**Send:**
```json
{
  "query": "Explain linear equations",
  "board": "CBSE",
  "standard": "9"
}
```

**Receive:**
```json
{
  "type": "processing",
  "message": "Processing your query..."
}
```

```json
{
  "type": "response",
  "query": "Explain linear equations",
  "response": {...},
  "board": "CBSE",
  "standard": "9"
}
```

---

## Statistics

### Get Content Statistics
**GET** `/api/content/stats/`

Get overall system statistics.

**Response:**
```json
{
  "total_chapters": 25,
  "total_subchapters": 150,
  "processed_subchapters": 120,
  "pending_subchapters": 30,
  "total_mcqs": 1200,
  "total_subjective": 600,
  "total_flashcards": 1200,
  "total_notes": 120,
  "boards": 3,
  "classes": 5,
  "subjects": 8
}
```

---

## WebSocket Events

### PDF Processing WebSocket
**WS** `ws://localhost:8002/ws/task/{task_id}/`

Real-time updates for PDF processing.

**Events:**
```json
{
  "status": "processing",
  "progress": 50,
  "message": "[Step 3/8] Generating hierarchy using LLM..."
}
```

```json
{
  "status": "Completed",
  "message": "File Processed",
  "disconnect": true,
  "data": {
    "status": true,
    "file": "filename.pdf",
    "chunks": 6,
    "message": "Success"
  }
}
```

---

## Error Responses

All APIs return standard error responses:

```json
{
  "error": "Error message here"
}
```

**HTTP Status Codes:**
- `200` - Success
- `202` - Accepted (async task started)
- `400` - Bad Request
- `404` - Not Found
- `500` - Internal Server Error

---

## Angular Integration Examples

### Service Example

```typescript
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class Concept360Service {
  private baseUrl = 'http://localhost:8002';

  constructor(private http: HttpClient) {}

  // Get chapters
  getChapters(board: string, className: string, subject: string): Observable<any> {
    return this.http.get(`${this.baseUrl}/api/content/chapters/`, {
      params: { board, class: className, subject }
    });
  }

  // Get MCQs
  getMCQs(subchapterId: number): Observable<any> {
    return this.http.get(`${this.baseUrl}/api/content/subchapters/${subchapterId}/mcqs/`);
  }

  // Generate content
  generateContent(data: any): Observable<any> {
    return this.http.post(`${this.baseUrl}/api/content/generate/`, data);
  }

  // Upload PDF
  uploadPDF(formData: FormData): Observable<any> {
    return this.http.post(`${this.baseUrl}/`, formData);
  }
}
```

### WebSocket Example

```typescript
const ws = new WebSocket('ws://localhost:8002/ws/chat/');

ws.onopen = () => {
  ws.send(JSON.stringify({
    query: 'What is a linear equation?',
    board: 'CBSE',
    standard: '9'
  }));
};

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('Response:', data);
  
  // Handle images in response
  if (data.response?.context) {
    data.response.context.forEach(ctx => {
      if (ctx.metadata?.image_urls) {
        // Display images
        ctx.metadata.image_urls.forEach(url => {
          console.log('Image URL:', url);
        });
      }
    });
  }
};
```

---

## Notes for Frontend Development

1. **CORS is configured** for `http://localhost:4200`
2. **WebSocket connections** are available for real-time updates
3. **Image URLs** are included in chat responses - parse and display them
4. **File downloads** use standard browser download mechanism
5. **Task IDs** should be stored for status polling
6. **Force regeneration** is available via `force=true` parameter

---

## Recommended Angular UI Structure

### Screens/Components:

1. **Dashboard**
   - Display statistics (`/api/content/stats/`)
   - Quick access to recent content

2. **Upload Screen**
   - PDF upload form
   - WebSocket connection for live progress
   - Display processing steps

3. **Browse Content**
   - Filter by Board/Class/Subject
   - List chapters and subchapters
   - Show processed status

4. **Subchapter Detail**
   - View notes (markdown or PDF)
   - Tabs for MCQs, Subjective, Flashcards
   - Generate content button

5. **MCQ Practice**
   - Display questions with options
   - Track answers
   - Show results

6. **Flashcard Study**
   - Flip card interface
   - Navigate through cards
   - Mark as learned

7. **Chat Interface**
   - WebSocket-based chat
   - Display text and images
   - Conversation history

---

**Last Updated:** March 17, 2026
