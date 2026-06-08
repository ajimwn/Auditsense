import io
from typing import Optional
from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from pypdf import PdfReader
import docx
from nlp_engine.analyzer import extract_policy_keywords

app = FastAPI()

# Add CORS Middleware for Flutter Web/Desktop connectivity
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class PolicyRequest(BaseModel):
    text: Optional[str] = None

@app.get("/")
def read_root():
    return {"status": "success", "message": "The AuditSense Analysis Engine is running!"}

@app.post("/analyze")
async def analyze_document(
    file: Optional[UploadFile] = File(None),
    text: Optional[str] = Form(None)
):
    """
    Clean PDF/Docx Text Extraction
    Inspects incoming files and extracts clean, human-readable text before analysis.
    """
    clean_payload = ""

    # 1. Handle File Upload (PDF/Docx/Txt)
    if file:
        content = await file.read()
        filename = file.filename.lower() if file.filename else ""

        try:
            if filename.endswith(".pdf"):
                # Use pypdf for reliable extraction
                reader = PdfReader(io.BytesIO(content))
                text_parts = []
                for page in reader.pages:
                    part = page.extract_text()
                    if part:
                        text_parts.append(part)
                clean_payload = "\n".join(text_parts)

            elif filename.endswith(".docx"):
                # Use python-docx for word documents
                doc = docx.Document(io.BytesIO(content))
                clean_payload = "\n".join([para.text for para in doc.paragraphs])

            elif filename.endswith(".txt"):
                clean_payload = content.decode("utf-8", errors="ignore")
            
            else:
                raise HTTPException(status_code=400, detail="Unsupported file format. Please upload PDF, DOCX, or TXT.")

        except HTTPException:
            raise
        except Exception as e:
            print(f"Extraction Error: {e}")
            raise HTTPException(status_code=500, detail="The Analysis Engine failed to extract text from the provided document.")

    # 2. Handle Raw Text (Fallback or direct paste)
    elif text:
        clean_payload = text

    else:
        raise HTTPException(status_code=400, detail="No valid policy content detected. Please provide text or a document file.")

    # Validation
    if not clean_payload.strip() or len(clean_payload.strip()) < 10:
        raise HTTPException(status_code=400, detail="Insufficient text content detected for analysis.")

    # Pass thoroughly cleaned string to analysis engine
    results = extract_policy_keywords(clean_payload)
    return results

@app.post("/analyze-text")
def analyze_text_legacy(request: PolicyRequest):
    """ Legacy endpoint for direct JSON text analysis """
    if not request.text or len(request.text.strip()) < 5:
        raise HTTPException(status_code=400, detail="No valid text provided.")
    return extract_policy_keywords(request.text)
