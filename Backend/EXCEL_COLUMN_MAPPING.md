# Excel Column Mapping for Content Generation

## Your Excel Structure

Based on your uploaded Excel file, here are the columns:

### Required Columns (Hierarchy)
1. **Board** - e.g., "CBSE"
2. **Class** - e.g., "9" (will be normalized from "9.0")
3. **Subject** - e.g., "Science"
4. **Chapter** - e.g., "Is Matter Around Us Pure"

### Content Columns
5. **Topic** - e.g., "Mixture Introduction"
6. **Sub-Chapter(Genesis Dimensions)** - This is the **content_name** that will be stored in `ChapterContent`

### Content Type Counts
7. **Sub-Chapter-wise Notes** - Notes flag
8. **Solved Questions** - Solved questions from book
9. **Flash Cards** - Flashcards count (can be empty - AI will determine)
10. **Objective Question Bank: MCQ** - Number of MCQs
11. **Objective Question Bank: FIB** - Number of Fill-in-the-Blank
12. **Objective Question Bank: TOF** - Number of True/False
13. **Subjective Question Bank: Short** - Number of short answer questions
14. **Subjective Question Bank: Long** - Number of long answer questions

## How It Works

### 1. Excel Upload
```
User uploads Excel → System reads all columns as-is
↓
Normalizes ONLY: Board, Class, Subject, Chapter, Topic
↓
Preserves ALL other columns with original names
```

### 2. Row Processing
```python
row_data = {
    'Board': 'CBSE',
    'Class': '9',  # Normalized from 9.0
    'Subject': 'Science',
    'Chapter': 'Is Matter Around Us Pure',
    'Topic': 'Mixture Introduction',
    'Sub-Chapter(Genesis Dimensions)': 'Mixture Introduction',  # Original column name preserved
    'Objective Question Bank: MCQ': 10,
    'Objective Question Bank: FIB': 10,
    'Objective Question Bank: TOF': 10,
    'Subjective Question Bank: Short': 1,
    'Subjective Question Bank: Long': 1,
    'Flash Cards': '',  # Empty - AI will determine
    # ... other columns
}
```

### 3. ChapterContent Creation
```python
content_name = row_data.get('Sub-Chapter(Genesis Dimensions)', '')
# → "Mixture Introduction"

chapter_content = ChapterContent.objects.create(
    chapter=chapter_obj,
    content_name="Mixture Introduction",
    excel_upload=excel_upload
)
```

### 4. Content Generation
```python
generate_educational_content(
    board='CBSE',
    standard='9',
    subject='Science',
    chapter='Is Matter Around Us Pure',
    sub_chapter='Mixture Introduction',  # From Sub-Chapter(Genesis Dimensions)
    topic='Mixture Introduction',
    num_mcqs=10,
    num_subjective_short=1,
    num_subjective_long=1,
    num_flashcards=0,  # AI-determined
    num_fib=10,
    num_tof=10,
    force=True
)
```

### 5. Content Storage
```python
# All content is stored with chapter_content FK
SubChapterMCQ.objects.create(
    chapter_content=chapter_content,  # Links to "Mixture Introduction"
    question="...",
    option_a="...",
    # ...
)
```

## Column Name Handling

### Preserved Columns (Original Names)
- ✅ `Sub-Chapter(Genesis Dimensions)` - Used for content_name
- ✅ `Objective Question Bank: MCQ` - MCQ count
- ✅ `Objective Question Bank: FIB` - FIB count
- ✅ `Objective Question Bank: TOF` - TOF count
- ✅ `Subjective Question Bank: Short` - Short answer count
- ✅ `Subjective Question Bank: Long` - Long answer count
- ✅ `Flash Cards` - Flashcard count (empty = AI-determined)
- ✅ `Sub-Chapter-wise Notes` - Notes flag
- ✅ `Solved Questions` - Solved questions flag

### Normalized Columns
- ✅ `Board` → `Board`
- ✅ `Class` → `Class` (9.0 → 9)
- ✅ `Subject` → `Subject`
- ✅ `Chapter` → `Chapter`
- ✅ `Topic` → `Topic`

## Safe Integer Conversion

All numeric columns use `safe_int()` function:
```python
def safe_int(value, default=0):
    if value == '' or value is None:
        return default
    try:
        return int(float(value))
    except (ValueError, TypeError):
        return default
```

This handles:
- Empty strings: `''` → `0`
- None values: `None` → `0`
- Float strings: `'10.0'` → `10`
- Invalid values: `'abc'` → `0`

## Flashcard AI Mode

When `Flash Cards` column is empty or 0:
```
Flash Cards: '' or 0
↓
AI determines optimal number
↓
Generates 15+ flashcards covering:
- Important concepts
- Formulas
- Definitions
- Key points
```

## Example Row Processing

**Excel Row:**
```
Board: CBSE
Class: 9
Subject: Science
Chapter: Is Matter Around Us Pure
Topic: Mixture Introduction
Sub-Chapter(Genesis Dimensions): Mixture Introduction
Objective Question Bank: MCQ: 10
Objective Question Bank: FIB: 10
Objective Question Bank: TOF: 10
Subjective Question Bank: Short: 1
Subjective Question Bank: Long: 1
Flash Cards: (empty)
```

**Result:**
```
✓ ChapterContent created: "Mixture Introduction"
✓ Generates: 10 MCQs, 1 Short, 1 Long, 15+ Flashcards (AI), 10 FIB, 10 TOF
✓ All linked to chapter_content_id
```

## Troubleshooting

### Issue: "Content name (sub_chapter) is required"
**Cause**: `Sub-Chapter(Genesis Dimensions)` column is empty
**Fix**: Ensure every row has a value in this column

### Issue: "invalid literal for int() with base 10: ''"
**Cause**: Empty string in numeric column
**Fix**: ✅ Already fixed with `safe_int()` function

### Issue: "Class '9.0' not found"
**Cause**: Excel reads "9" as float "9.0"
**Fix**: ✅ Already fixed with class normalization
