from fastapi import FastAPI, Query
from typing import List
import pandas as pd
import torch
from sentence_transformers import SentenceTransformer, util
import pickle
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Allow CORS for frontend integration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load a reduced dataset to fit Render free tier memory
print("🔄 Loading dataset...")
df = pd.read_csv("data/recipes.csv").head(2000)  # Load only top 2000 for now
print("✅ Dataset loaded: ", len(df), "recipes")

model = SentenceTransformer("paraphrase-MiniLM-L3-v2")

# Load the reduced vector DB
print("📦 Loading recipe vectors...")
with open("data/vector_db.pkl", "rb") as f:
    vector_db = pickle.load(f)

recipe_vectors = vector_db["vectors"]
print("✅ Vector DB loaded with shape:", recipe_vectors.shape)

@app.get("/semantic_recommend")
def recommend_semantic(ingredients: str = Query(...)):
    user_ings = [ing.strip().lower() for ing in ingredients.split(",") if ing.strip()]
    if not user_ings:
        return {"error": "Please provide ingredients."}

    user_embedding = model.encode(
        ", ".join(user_ings), convert_to_tensor=True, normalize_embeddings=True
    )

    scores = util.cos_sim(user_embedding, recipe_vectors)[0]
    top_indices = torch.topk(scores, k=10).indices.tolist()

    results = []
    for idx in top_indices:
        results.append({
            "name": df.iloc[idx]["name"],
            "ingredients": eval(df.iloc[idx]["ingredients"]),
            "score": round(float(scores[idx]), 3),
        })

    return results
