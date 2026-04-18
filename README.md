# 🌿 PlantGuard AI | Smart Plant Disease Diagnostic System

[![Python](https://img.shields.io/badge/Python-3.9+-3776AB?style=flat-square&logo=python&logoColor=white)](https://www.python.org/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev/)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Django](https://img.shields.io/badge/Django_REST-3.x-092E20?style=flat-square&logo=django&logoColor=white)](https://www.django-rest-framework.org/)
[![PyTorch](https://img.shields.io/badge/PyTorch-2.x-EE4C2C?style=flat-square&logo=pytorch&logoColor=white)](https://pytorch.org/)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

> **A production-ready, offline-capable plant disease diagnostic platform** — powered by Vision Transformers, an on-device LLM chatbot, and a Flutter mobile app built for real field conditions.

---

## 📋 Overview

PlantGuard AI is a smart agriculture system that puts expert-level plant disease detection in the hands of any farmer — no internet required. By combining a fine-tuned **Vision Transformer (ViT)** for image-based diagnosis with a **LLaMA-3.2-1B** chatbot for agricultural guidance, the platform delivers real-time, reliable results directly from a smartphone camera.

The system was trained across three diverse plant disease datasets and optimized for edge inference, enabling deployment in remote areas where connectivity is limited or unavailable.

**Built for:** Farmers, agronomists, and agricultural researchers.

---

## 🎯 Key Features

### 🔬 Disease Detection
- Real-time leaf disease classification via Vision Transformer (ViT)
- Transfer learning fine-tuned on 3 combined datasets
- Supports dozens of crop species and disease categories
- High accuracy under natural field lighting conditions

### 🤖 AI Chatbot Assistant
- On-device LLaMA-3.2-1B for treatment recommendations
- Context-aware responses based on detected disease
- Works fully offline after initial model download
- Natural language Q&A for farmers of any tech level

### 📱 Mobile Experience
- Cross-platform Flutter app (Android & iOS)
- Camera-first UI designed for field use
- Instant results with confidence scores
- Offline mode with local model inference
- Diagnosis history and export

### ⚙️ Backend & API
- Django REST Framework for scalable API
- Image preprocessing and augmentation pipeline
- Secure authentication and user management
- REST endpoints for detection, chatbot, and history

---

## 🛠️ Tech Stack

| Layer | Technology | Link |
|---|---|---|
| **Mobile App** | Flutter 3.x (Dart) | [flutter.dev](https://flutter.dev/) |
| **Backend API** | Django REST Framework | [django-rest-framework.org](https://www.django-rest-framework.org/) |
| **Disease Model** | Vision Transformer (ViT) | [HuggingFace ViT](https://huggingface.co/google/vit-base-patch16-224) |
| **Chatbot Model** | LLaMA-3.2-1B | [Meta LLaMA](https://ai.meta.com/llama/) |
| **ML Framework** | PyTorch | [pytorch.org](https://pytorch.org/) |
| **Transformers** | HuggingFace Transformers | [huggingface.co](https://huggingface.co/) |
| **Language** | Python 3.9+ / Dart 3.x | — |
| **Dev Tools** | VS Code, Git | [code.visualstudio.com](https://code.visualstudio.com/) |

---

## 📊 Datasets

The model was trained and validated on a combination of three publicly available plant disease datasets to maximize real-world generalization:

| Dataset | Type | Description |
|---|---|---|
| **PlantVillage** | Lab-controlled | 54,000+ images across 38 disease classes — the primary training benchmark |
| **PlantDoc** | Real-world field | Images collected under natural conditions for improved generalization |
| **Plant Wild** | Wild/uncontrolled | Diverse environments and lighting to handle edge cases in the field |

> Training on all three datasets together ensures the model handles the messy, real-world images that a farmer's phone camera actually produces.

---

## 🧠 Model Architecture

### Vision Transformer (ViT) — Disease Classifier
```
Input Image (224x224)
       │
  Patch Embedding (16x16 patches)
       │
  Transformer Encoder (12 layers)
       │
  Classification Head
       │
  Disease Label + Confidence Score
```
- **Backbone**: `google/vit-base-patch16-224` (pretrained on ImageNet-21k)
- **Fine-tuning**: Transfer learning on PlantVillage + PlantDoc + PlantWild
- **Output**: Multi-class disease classification with confidence scores

### LLaMA-3.2-1B — Chatbot Advisor
- **Model**: Meta LLaMA-3.2-1B (quantized for mobile inference)
- **Role**: Provides treatment advice, prevention tips, and answers farmer queries
- **Context**: Receives detected disease label as context for grounded responses

---

## 📥 Installation Guide

### Prerequisites

Make sure the following are installed before you begin:

| Tool | Version | Download |
|---|---|---|
| Python | 3.9+ | [python.org](https://www.python.org/downloads/) |
| Flutter SDK | 3.x | [flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install) |
| Git | Latest | [git-scm.com](https://git-scm.com/downloads) |
| VS Code *(recommended)* | Latest | [code.visualstudio.com](https://code.visualstudio.com/) |

---

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/plantguard-ai.git
cd plantguard-ai
```

---

### 2. Backend Setup (Django REST Framework)

```bash
cd backend

# Create and activate a virtual environment
python -m venv venv
source venv/bin/activate        # macOS/Linux
venv\Scripts\activate           # Windows

# Install Python dependencies
pip install -r requirements.txt

# Apply database migrations
python manage.py migrate

# (Optional) Create a superuser for the admin panel
python manage.py createsuperuser

# Start the development server
python manage.py runserver
```

> The API will be available at `http://127.0.0.1:8000/api/`

---

### 3. Mobile App Setup (Flutter)

```bash
cd mobile

# Install Flutter dependencies
flutter pub get

# Check your environment
flutter doctor

# Run on a connected device or emulator
flutter run

# Build release APK (Android)
flutter build apk --release

# Build for iOS
flutter build ios --release
```

---

### 4. ML Model Setup

```bash
cd ml

# Install ML-specific dependencies
pip install -r requirements.txt

# Download pretrained ViT weights (first run only)
python download_models.py

# Run inference on a single image
python predict.py --image path/to/leaf.jpg

# Fine-tune on combined datasets
python train_vit.py --epochs 30 --batch-size 32

# Launch the chatbot in CLI mode
python chatbot.py
```

---

## 📁 Project Structure

```
plantguard-ai/
│
├── backend/                        # Django REST Framework API
│   ├── api/
│   │   ├── views.py                # Detection, chat, history endpoints
│   │   ├── serializers.py
│   │   └── urls.py
│   ├── inference/
│   │   ├── vit_model.py            # ViT inference wrapper
│   │   └── llama_chatbot.py        # LLaMA inference wrapper
│   ├── config/
│   │   └── settings.py
│   ├── manage.py
│   └── requirements.txt
│
├── mobile/                         # Flutter application
│   ├── lib/
│   │   ├── screens/
│   │   │   ├── camera_screen.dart  # Live camera capture
│   │   │   ├── result_screen.dart  # Diagnosis results
│   │   │   └── chat_screen.dart    # LLaMA chatbot UI
│   │   ├── services/
│   │   │   ├── api_service.dart    # Backend API calls
│   │   │   └── offline_service.dart
│   │   └── widgets/
│   └── pubspec.yaml
│
├── ml/                             # Model training & evaluation
│   ├── train_vit.py                # ViT fine-tuning pipeline
│   ├── evaluate.py                 # Accuracy, F1, confusion matrix
│   ├── predict.py                  # Single-image inference
│   ├── chatbot.py                  # LLaMA CLI interface
│   ├── datasets/
│   │   ├── plantvillage_loader.py
│   │   ├── plantdoc_loader.py
│   │   └── plantwild_loader.py
│   └── checkpoints/                # Saved model weights (.pt)
│
└── README.md
```

---

## 📈 Model Performance

> Evaluated on a combined held-out test set across all three datasets.

| Metric | ViT (Disease Detection) |
|---|---|
| Top-1 Accuracy | *TBD* |
| Precision (macro) | *TBD* |
| Recall (macro) | *TBD* |
| F1-Score (macro) | *TBD* |
| Inference Time (server) | *TBD* |
| Inference Time (mobile) | *TBD* |

---

## 🌐 API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/detect/` | Upload leaf image → returns disease label + confidence |
| `POST` | `/api/chat/` | Send message → returns LLaMA chatbot response |
| `GET` | `/api/history/` | Retrieve past diagnoses for authenticated user |
| `POST` | `/api/auth/register/` | Register new user account |
| `POST` | `/api/auth/login/` | Obtain authentication token |

---

## 💡 Usage Example

```python
import requests

# Detect plant disease from an image
with open("leaf.jpg", "rb") as img:
    response = requests.post(
        "http://127.0.0.1:8000/api/detect/",
        files={"image": img},
        headers={"Authorization": "Token your_token_here"}
    )

result = response.json()
print(result)
# {
#   "disease": "Tomato Late Blight",
#   "confidence": 0.94,
#   "crop": "Tomato",
#   "severity": "High"
# }
```

---

## 🤝 Contributing

Contributions are welcome! To get started:

1. Fork the repository
2. Create a feature branch — `git checkout -b feature/your-feature`
3. Commit your changes — `git commit -m "Add your feature"`
4. Push to your branch — `git push origin feature/your-feature`
5. Open a Pull Request targeting the `dev` branch

Please open an issue first for major changes so we can discuss the approach.


## 👤 Author

**Abderrahmane Moumene**

---

<p align="center">Built with 🌿 to make smart agriculture accessible to every farmer.</p>
