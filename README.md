    # 🌿 PlantGuard AI — Intelligent Plant Disease Diagnostic System

    > Real-time, offline-capable plant disease detection powered by Vision Transformers and an on-device LLM assistant — built for the field, not the lab.

    ---

    ## 📖 Overview

    PlantGuard AI is a smart agriculture diagnostic platform that brings expert-level plant disease detection to any farmer's pocket. By combining state-of-the-art deep learning with edge computing, the system delivers accurate, real-time crop diagnostics — **no internet required**.

    The platform addresses one of modern agriculture's most critical challenges: scalable, affordable, and accessible disease detection at the point of need. It consists of a mobile application (Flutter), a robust backend API (Django REST Framework), and a fine-tuned AI pipeline capable of running both on-server and on-device.

    ---

    ## ✨ Key Features

    - 🔍 **Real-Time Disease Detection** — Instant image-based diagnosis using Vision Transformer (ViT)
    - 📴 **Offline-Capable** — Fully functional in remote areas with no internet connectivity
    - 🤖 **AI Chatbot Assistant** — Context-aware agricultural guidance powered by LLaMA-3.2-1B
    - 📱 **Cross-Platform Mobile App** — Native Android & iOS experience via Flutter
    - 🌍 **Multi-Dataset Training** — Robust generalization across diverse plant species and conditions
    - ⚡ **Edge Inference** — Optimized model inference for low-resource mobile hardware

    ---

    ## 🏗️ Architecture

    ```
    ┌─────────────────────────────────────────────────────────┐
    │                     Flutter App (Dart)                   │
    │         Camera Input │ Chatbot UI │ Results Dashboard    │
    └────────────────────────────┬────────────────────────────┘
                                │ HTTP / REST
    ┌────────────────────────────▼────────────────────────────┐
    │              Django REST Framework (Python)              │
    │         Authentication │ Image API │ Inference Engine    │
    └──────────────┬─────────────────────────┬────────────────┘
                │                         │
    ┌──────────────▼──────────┐   ┌──────────▼───────────────┐
    │  Vision Transformer     │   │   LLaMA-3.2-1B Chatbot   │
    │  (ViT) Disease Detector │   │   Agricultural Advisor    │
    └─────────────────────────┘   └──────────────────────────┘
    ```

    ---

    ## 🧠 AI & ML Stack

    ### Disease Detection — Vision Transformer (ViT)

    Transfer learning with ViT for image classification:

    - **Architecture**: Vision Transformer (ViT-B/16 backbone)
    - **Task**: Multi-class plant disease classification
    - **Approach**: Fine-tuned via transfer learning on domain-specific datasets
    - **Input**: Leaf images captured from mobile camera

    ### Chatbot — LLaMA-3.2-1B

    An on-device large language model for interactive agricultural guidance:

    - **Model**: LLaMA-3.2-1B
    - **Purpose**: Answer disease-related queries, provide treatment recommendations, and guide farmers
    - **Deployment**: Optimized for mobile/edge inference

    ---

    ## 📊 Datasets

    The model was trained and evaluated on a combination of three publicly available plant disease datasets:

    | Dataset | Description |
    |---|---|
    | **PlantVillage** | Large-scale benchmark dataset with 54,000+ lab-controlled leaf images across 38 disease classes |
    | **PlantDoc** | Real-world images collected under natural field conditions for improved generalization |
    | **Plant Wild** | Diverse wild plant images to improve robustness under uncontrolled environments |

    Training on multiple datasets ensures the model performs reliably across varied lighting, backgrounds, and crop types encountered in real field conditions.

    ---

    ## 🛠️ Technology Stack

    | Layer | Technology |
    |---|---|
    | **Mobile App** | Flutter (Dart) |
    | **Backend API** | Django REST Framework (Python) |
    | **Disease Detection Model** | Vision Transformer (ViT) via Transfer Learning |
    | **Chatbot Model** | LLaMA-3.2-1B |
    | **Primary Language** | Python, Dart |

    ---

    ## 🚀 Getting Started

    ### Prerequisites

    - Python 3.9+
    - Flutter SDK 3.x
    - pip / virtualenv

    ### Backend Setup

    ```bash
    # Clone the repository
    git clone https://github.com/your-username/plantguard-ai.git
    cd plantguard-ai/backend

    # Create and activate virtual environment
    python -m venv venv
    source venv/bin/activate  # On Windows: venv\Scripts\activate

    # Install dependencies
    pip install -r requirements.txt

    # Run migrations
    python manage.py migrate

    # Start the development server
    python manage.py runserver
    ```

    ### Mobile App Setup

    ```bash
    cd ../mobile

    # Install Flutter dependencies
    flutter pub get

    # Run on connected device or emulator
    flutter run
    ```

    ### Model Inference (standalone)

    ```bash
    cd ../models

    # Run ViT inference on a sample image
    python predict.py --image path/to/leaf.jpg

    # Launch chatbot CLI
    python chatbot.py
    ```

    ---

    ## 📁 Project Structure

    ```
    plantguard-ai/
    ├── backend/                  # Django REST Framework API
    │   ├── api/                  # Endpoints: detection, chat, auth
    │   ├── models/               # Inference wrappers (ViT + LLaMA)
    │   ├── config/               # Django settings
    │   └── requirements.txt
    │
    ├── mobile/                   # Flutter application
    │   ├── lib/
    │   │   ├── screens/          # Camera, results, chatbot UI
    │   │   ├── services/         # API calls, offline logic
    │   │   └── widgets/          # Reusable UI components
    │   └── pubspec.yaml
    │
    ├── ml/                       # Model training & evaluation
    │   ├── train_vit.py          # ViT fine-tuning pipeline
    │   ├── evaluate.py           # Metrics and benchmarks
    │   ├── datasets/             # Data loaders for PlantVillage, PlantDoc, PlantWild
    │   └── checkpoints/          # Saved model weights
    │
    └── README.md
    ```

    ---

    ## 📈 Model Performance

    > Results on held-out test sets across combined datasets.

    | Metric | Score |
    |---|---|
    | Top-1 Accuracy | *coming soon* |
    | Precision | *coming soon* |
    | Recall | *coming soon* |
    | F1-Score | *coming soon* |
    | Inference Time (mobile) | *coming soon* |

    ---

    ## 🌱 Motivation

    Global food security depends on protecting crop yields. Traditional disease diagnosis requires expert agronomists on-site — a resource most smallholder farmers around the world simply don't have access to. PlantGuard AI was built to change that: putting expert-level diagnostics in the hands of any farmer, anywhere, on a standard smartphone.

    ---

    ## 🤝 Contributing

    Contributions are welcome! Please open an issue first to discuss what you'd like to change. Pull requests should be made to the `dev` branch.

    1. Fork the repository
    2. Create your feature branch (`git checkout -b feature/your-feature`)
    3. Commit your changes (`git commit -m 'Add your feature'`)
    4. Push to the branch (`git push origin feature/your-feature`)
    5. Open a pull request

    ---

    ## 📄 License

    This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

    ---

    ## 📬 Contact

    Have questions or want to collaborate? Open an issue or reach out via the repository discussions tab.

    ---

    <p align="center">Built with 🌿 to feed the world smarter.</p>
