# Roadmap: Note → Summary → Quiz App

This document outlines an agile-style development roadmap for building an iOS app that:
- Captures or uploads handwritten notes,
- Converts them to digital text via OCR,
- Sends text to a free LLM endpoint for summarization and quiz generation,
- Returns the summary and renders an interactive quiz.

Each sprint is estimated at 1–2 weeks depending on workload.

---

## Sprint 1: Image Capture and OCR
**Goal:** Enable the app to take or select photos and extract text using on-device OCR.

**Tasks:**
- Implement photo selection via `PHPickerViewController`.
- Implement camera capture via `UIImagePickerController`.
- Integrate Apple Vision framework (`VNRecognizeTextRequest`) to extract text.
- Display extracted text in the UI.
- Test OCR accuracy on handwritten notes.

**Deliverables:**
- Functional photo capture/selection.
- OCR text visible in-app after upload.

---

## Sprint 2: LLM Integration
**Goal:** Connect OCR output to a free hosted LLM endpoint (Hugging Face Inference API or Gemini free tier).

**Tasks:**
- Register for Hugging Face Inference API (free tier) and obtain key.
- Implement API client in Swift for POST requests.
- Define JSON-based prompt format:
  - Summary: 3–5 bullet points.
  - Quiz: 5 multiple-choice questions.
- Parse JSON response into Swift data models (`Summary`, `QuizQuestion`).
- Add error handling for free tier limits.

**Deliverables:**
- End-to-end flow: Upload → OCR → API call → summary and quiz in raw text.

---

## Sprint 3: Quiz Interaction and UI
**Goal:** Build an interactive quiz component and refine summary presentation.

**Tasks:**
- Create SwiftUI `QuizView` to display questions and multiple-choice options.
- Implement answer selection with immediate feedback (correct/incorrect).
- Style summary view with bullets and headers.
- Add navigation flow: Upload → Summary → Quiz.

**Deliverables:**
- Interactive quiz working in-app.
- Clear, readable summary display.

---

## Sprint 4: Persistence and History
**Goal:** Store and review past study sessions.

**Tasks:**
- Implement CoreData or local JSON storage for summaries and quizzes.
- Build “History” tab showing list of past sessions.
- Add detail view to reopen past summaries/quizzes.
- Implement delete/archive functionality.

**Deliverables:**
- Users can review and manage past notes and quizzes.

---

## Sprint 5: Refinement and Export
**Goal:** Polish UI/UX and add export options.

**Tasks:**
- Add settings screen for managing API keys and switching endpoints.
- Implement export of summaries as Markdown or PDF.
- Refine quiz formatting and styling.
- Test usability with actual study notes.

**Deliverables:**
- Polished app with export/share support.
- Smooth daily workflow for 4–6 uploads/day.

---

## Sprint 6: Deployment and Maintenance
**Goal:** Ensure sustainable use on-device with free provisioning.

**Tasks:**
- Test sideloading with free Apple ID (weekly re-sign).
- Document process for refreshing the app on device.
- Monitor API usage and document fallback (e.g., Gemini free tier).
- Collect feedback from real usage and adjust prompts.

**Deliverables:**
- Stable app running on personal device.
- Sustainable workflow without paid subscriptions.

---
