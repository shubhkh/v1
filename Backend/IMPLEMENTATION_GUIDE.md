# Implementation Guide: Chapter-Level Content Storage

## Quick Reference

### Model Structure
```
Chapter (existing)
    ↓
ChapterContent (NEW - one per Excel row)
    ├── content_name (from Excel "Sub-Chapter" column)
    ├── chapter (FK)
    └── excel_upload (FK)
    ↓
Content Models (MCQ, Subjective, Notes, etc.)
    └── chapter_content (FK)
```

## Code Examples

### 1. Excel Upload Processing

```python
# In your Excel processing view/service
from contentGen.models import ChapterContent, ExcelUpload

def process_excel_row(row_data, excel_upload):
    # Get or identify the chapter
    chapter = Chapter.objects.get(
        board__name=row_data['Board'],
        class_field__standard=row_data['Standard'],
        subject__subject=row_data['Subject'],
        chapter_name=row_data['Chapter']
    )
    
    # Create ChapterContent for this row
    chapter_content = ChapterContent.objects.create(
        chapter=chapter,
        content_name=row_data['Sub-Chapter(Genesis Dimensions)'],
        excel_upload=excel_upload
    )
    
    # Create ExcelRowGeneration tracking
    row_gen = ExcelRowGeneration.objects.create(
        excel_upload=excel_upload,
        row_number=row_data['row_number'],
        board=chapter.board,
        class_field=chapter.class_field,
        subject=chapter.subject,
        chapter=chapter,
        chapter_content=chapter_content,  # Link to ChapterContent
        num_mcqs_requested=row_data.get('Objective Question Bank- MCQ', 0),
        num_subjective_short_requested=row_data.get('Subjective Question Bank-Short', 0),
        num_subjective_long_requested=row_data.get('Subjective Question Bank- Long', 0),
        num_flashcards_requested=row_data.get('Flash Cards', 0),
        num_fib_requested=row_data.get('Objective Question Bank- FIB', 0),
        num_tof_requested=row_data.get('Objective Question Bank- TOF', 0),
        notes_requested=row_data.get('Sub-Chapter-wise Notes Dimension1 Notes', False)
    )
    
    return chapter_content, row_gen
```

### 2. Content Generation

```python
# When generating MCQs
from contentGen.models import SubChapterMCQ, ChapterContent

def generate_mcqs(chapter_content_id, count=10):
    chapter_content = ChapterContent.objects.get(id=chapter_content_id)
    
    # Your AI generation logic here
    generated_mcqs = ai_generate_mcqs(
        chapter=chapter_content.chapter,
        content_name=chapter_content.content_name,
        count=count
    )
    
    # Save to database
    mcq_objects = []
    for mcq_data in generated_mcqs:
        mcq = SubChapterMCQ(
            chapter_content=chapter_content,
            question=mcq_data['question'],
            option_a=mcq_data['option_a'],
            option_b=mcq_data['option_b'],
            option_c=mcq_data['option_c'],
            option_d=mcq_data['option_d'],
            correct_answer=mcq_data['correct_answer']
        )
        mcq_objects.append(mcq)
    
    SubChapterMCQ.objects.bulk_create(mcq_objects)
    return len(mcq_objects)
```

### 3. Content Generation Log

```python
from contentGen.models import ContentGenerationLog

def log_content_generation(chapter_content, content_type, task_id):
    log = ContentGenerationLog.objects.create(
        chapter_content=chapter_content,
        content_type=content_type,  # 'mcq', 'subjective_short', etc.
        status='in_progress',
        task_id=task_id
    )
    return log

# Mark as completed
def mark_generation_complete(log_id, quantity):
    log = ContentGenerationLog.objects.get(id=log_id)
    log.mark_completed(quantity=quantity)
```

### 4. Querying Content

```python
# Get all content for a chapter
chapter = Chapter.objects.get(id=1)
chapter_contents = ChapterContent.objects.filter(chapter=chapter)

for content in chapter_contents:
    print(f"Content: {content.content_name}")
    print(f"  MCQs: {content.mcqs.count()}")
    print(f"  Subjective: {content.subjective_questions.count()}")
    print(f"  Notes: {content.notes.count()}")
    print(f"  Flashcards: {content.flashcards.count()}")

# Get specific content by name
chapter_content = ChapterContent.objects.get(
    chapter=chapter,
    content_name="Matter around us pure"
)

# Get all MCQs for this content
mcqs = chapter_content.mcqs.all()

# Get content from Excel upload
excel_upload = ExcelUpload.objects.get(file_id="some-file-id")
contents = excel_upload.chapter_contents.all()
```

### 5. API Serializer Example

```python
from rest_framework import serializers
from contentGen.models import ChapterContent, SubChapterMCQ

class ChapterContentSerializer(serializers.ModelSerializer):
    chapter_name = serializers.CharField(source='chapter.chapter_name', read_only=True)
    board_name = serializers.CharField(source='chapter.board.name', read_only=True)
    
    class Meta:
        model = ChapterContent
        fields = ['id', 'chapter', 'chapter_name', 'board_name', 
                  'content_name', 'created_at']

class MCQSerializer(serializers.ModelSerializer):
    chapter_content_name = serializers.CharField(
        source='chapter_content.content_name', 
        read_only=True
    )
    
    class Meta:
        model = SubChapterMCQ
        fields = ['id', 'chapter_content', 'chapter_content_name',
                  'question', 'option_a', 'option_b', 'option_c', 
                  'option_d', 'correct_answer', 'created_at']
```

## Files to Update

### 1. Excel Processing
- `contentGen/excel_views.py` - Update Excel upload processing
- `contentGen/utils/excel_content_generator.py` - Update content generation logic
- `contentGen/utils/excel_row_generation.py` - Update row processing

### 2. Content Generation
- `contentGen/utils/ContentGenerationGraph.py` - Update to use ChapterContent
- `contentGen/content_views.py` - Update content creation endpoints

### 3. Serializers & Views
- `contentGen/serializers.py` - Update serializers
- `contentGen/api_views.py` - Update API views

## Testing Checklist

- [ ] Upload Excel file
- [ ] Verify ChapterContent records created
- [ ] Generate MCQs for a ChapterContent
- [ ] Generate Subjective questions
- [ ] Generate Notes
- [ ] Generate Flashcards
- [ ] Verify ContentGenerationLog entries
- [ ] Test querying content by chapter
- [ ] Test querying content by Excel upload
- [ ] Test admin interface

## Migration Rollback (if needed)

If you need to rollback:
```bash
python3 manage.py migrate contentGen 0005_new_content_types_and_prompt_system
```

**Note**: This will delete the ChapterContent table and restore old structure.
