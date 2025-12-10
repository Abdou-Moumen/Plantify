import torch
from torchvision import transforms
from PIL import Image
import os
from timm.models.vision_transformer import VisionTransformer

class PlantDiseasePredictor:
    def __init__(self, confidence_threshold=0.5):
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.class_names = None
        self.model = None
        self.transform = None
        self.confidence_threshold = confidence_threshold
        self.initialize_model()
    
    def initialize_model(self):
        # ✅ Image transforms (match training)
        self.transform = transforms.Compose([
            transforms.Resize((224, 224)),  # ViT typically uses 224x224
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
        ])
        
        # ✅ Load class names from dataset
        from torchvision import datasets
        dataset = datasets.ImageFolder(root="AADataset", transform=self.transform)
        self.class_names = dataset.classes
        
        # ✅ Load trained model
        model_path = "vit_finetuned_plant_disease_full.pth"
        if not os.path.exists(model_path):
            raise FileNotFoundError(f"❌ Model file '{model_path}' not found.")
        
        from timm.layers.patch_embed import PatchEmbed
        torch.serialization.add_safe_globals([VisionTransformer, PatchEmbed])
        self.model = torch.load(model_path, map_location=self.device, weights_only=False)
        self.model.to(self.device)
        self.model.eval()
    
    def predict_image(self, image_path):
        # Check if image exists
        if not os.path.exists(image_path):
            raise FileNotFoundError(f"❌ Image path '{image_path}' not found.")
        
        # Load and preprocess the image
        image = Image.open(image_path).convert("RGB")  # Ensure RGB format
        image_tensor = self.transform(image).unsqueeze(0)  # Add batch dimension
        image_tensor = image_tensor.to(self.device)
        
        # Make prediction
        with torch.no_grad():
            outputs = self.model(image_tensor)
            _, predicted = outputs.max(1)
            confidence = outputs.softmax(1).max().item()  # Softmax for confidence score
            predicted_class = self.class_names[predicted.item()]
        
        # Return result with confidence
        result = {
            "predicted_class": predicted_class,
            "confidence": confidence,
            "is_reliable": confidence >= self.confidence_threshold
        }
        return result

# Singleton instance with 0.5 (50%) confidence threshold
predictor = PlantDiseasePredictor(confidence_threshold=0.5) 