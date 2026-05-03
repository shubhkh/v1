# Chapter Content API Endpoints

## New Chapter-Level Content APIs

### 1. List Chapter Contents
**GET** `/api/content/chapter-contents/?chapter_id={chapter_id}`

Get all content items for a specific chapter.

**Query Parameters:**
- `chapter_id` (required): ID of the chapter

**Response:**
```json
[
  {
    "id": 1,
    "chapter": 1,
    "chapter_name": "Matter in Our Surroundings",
    "board_name": "CBSE",
    "class_standard": "9",
    "subject_name": "Science",
    "content_name": "Matter around us pure",
    "excel_upload": 1,
    "created_at": "2026-04-24T08:00:00Z",
    "updated_at": "2026-04-24T08:00:00Z",
    "mcq_count": 10,
    "subjective_count": 5,
    "flashcard_count": 8,
    "notes_count": 1,
    "fib_count": 3,
    "tof_count": 4
  }
]
```

### 2. Get Chapter Content Detail
**GET** `/api/content/chapter-contents/{id}/`

Get detailed information about a specific chapter content including all generated content.

**Response:**
```json
{
  "chapter_content": {
    "id": 1,
    "chapter": 1,
    "chapter_name": "Matter in Our Surroundings",
    "content_name": "Matter around us pure",
    ...
  },
  "mcqs": [...],
  "subjective": [...],
  "flashcards": [...],
  "notes": [...]
}
```

### 3. Get MCQs for Chapter Content
**GET** `/api/content/chapter-contents/{id}/mcqs/`

Get all MCQs for a specific chapter content.

**Response:**
```json
[
  {
    "id": 1,
    "chapter_content": 1,
    "chapter_content_name": "Matter around us pure",
    "question": "What is matter?",
    "option_a": "Anything that has mass",
    "option_b": "Anything that occupies space",
    "option_c": "Both A and B",
    "option_d": "None of the above",
    "correct_answer": "C",
    "created_at": "2026-04-24T08:00:00Z"
  }
]
```

### 4. Get Subjective Questions for Chapter Content
**GET** `/api/content/chapter-contents/{id}/subjective/`

Get all subjective questions for a specific chapter content.

**Response:**
```json
[
  {
    "id": 1,
    "chapter_content": 1,
    "chapter_content_name": "Matter around us pure",
    "question": "Explain the states of matter.",
    "solution": "Matter exists in three states...",
    "short": false,
    "created_at": "2026-04-24T08:00:00Z"
  }
]
```

### 5. Get Flashcards for Chapter Content
**GET** `/api/content/chapter-contents/{id}/flashcards/`

Get all flashcards for a specific chapter content.

**Response:**
```json
[
  {
    "id": 1,
    "chapter_content": 1,
    "chapter_content_name": "Matter around us pure",
    "front": "What is the definition of matter?",
    "back": "Matter is anything that has mass and occupies space.",
    "created_at": "2026-04-24T08:00:00Z"
  }
]
```

## Updated Excel Upload API

### Upload Excel File
**POST** `/api/content/excel/upload/`

Upload an Excel file for content generation. Now creates `ChapterContent` records.

**Request:**
- `file`: Excel file (multipart/form-data)

**Excel Format:**
| Board | Standard | Subject | Chapter | Sub-Chapter(Genesis Dimensions) | Objective Question Bank- MCQ | ... |
|-------|----------|---------|---------|--------------------------------|------------------------------|-----|
| CBSE  | 9        | Science | Matter in Our Surroundings | Matter around us pure | 10 | ... |

**Response:**
```json
{
  "success": true,
  "file_id": "uuid-here",
  "excel_upload_id": 1,
  "total_rows": 10,
  "valid_rows": 8,
  "invalid_rows": 2,
  "validation_results": [...]
}
```

**Note:** For each valid row, the API now:
1. Creates a `ChapterContent` record with `content_name` from "Sub-Chapter(Genesis Dimensions)" column
2. Creates an `ExcelRowGeneration` record linked to the `ChapterContent`

## Updated Serializers

### ChapterContentSerializer
```json
{
  "id": 1,
  "chapter": 1,
  "chapter_name": "Matter in Our Surroundings",
  "board_name": "CBSE",
  "class_standard": "9",
  "subject_name": "Science",
  "content_name": "Matter around us pure",
  "excel_upload": 1,
  "created_at": "2026-04-24T08:00:00Z",
  "updated_at": "2026-04-24T08:00:00Z",
  "mcq_count": 10,
  "subjective_count": 5,
  "flashcard_count": 8,
  "notes_count": 1,
  "fib_count": 3,
  "tof_count": 4
}
```

### SubChapterMCQSerializer (Updated)
```json
{
  "id": 1,
  "chapter_content": 1,
  "chapter_content_name": "Matter around us pure",
  "question": "What is matter?",
  "option_a": "...",
  "option_b": "...",
  "option_c": "...",
  "option_d": "...",
  "correct_answer": "C",
  "created_at": "2026-04-24T08:00:00Z"
}
```

### ContentGenerationLogSerializer (Updated)
```json
{
  "id": 1,
  "board_name": "CBSE",
  "class_standard": "9",
  "subject_name": "Science",
  "chapter_name": "Matter in Our Surroundings",
  "content_name": "Matter around us pure",
  "chapter_content": 1,
  "content_type": "mcq",
  "status": "completed",
  "quantity": 10,
  "task_id": "task-uuid",
  "error_message": null,
  "started_at": "2026-04-24T08:00:00Z",
  "completed_at": "2026-04-24T08:05:00Z",
  "duration": 300.0
}
```

## Migration from Old to New

### Old Endpoints (Still Available - Legacy)
- `/api/content/subchapters/{subchapter_id}/mcqs/`
- `/api/content/subchapters/{subchapter_id}/subjective/`
- `/api/content/subchapters/{subchapter_id}/flashcards/`

### New Endpoints (Recommended)
- `/api/content/chapter-contents/?chapter_id={chapter_id}`
- `/api/content/chapter-contents/{id}/mcqs/`
- `/api/content/chapter-contents/{id}/subjective/`
- `/api/content/chapter-contents/{id}/flashcards/`

## Frontend Integration

### Example: Fetch Chapter Contents
```typescript
// Get all content for a chapter
const response = await fetch(`/api/content/chapter-contents/?chapter_id=${chapterId}`);
const chapterContents = await response.json();

// Display content names
chapterContents.forEach(content => {
  console.log(`${content.content_name}: ${content.mcq_count} MCQs, ${content.subjective_count} Subjective`);
});
```

### Example: Fetch MCQs for a Content
```typescript
// Get MCQs for a specific chapter content
const response = await fetch(`/api/content/chapter-contents/${contentId}/mcqs/`);
const mcqs = await response.json();
```
