from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Dict, Any
from rapidfuzz.fuzz import token_set_ratio
import datetime

app = FastAPI()

# Enable CORS for frontend access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Update this if you want to restrict to specific domains
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# FAQ data
faqs = {
    "delivery_time": {
        "question": "How long does delivery take?",
        "answer": "Delivery typically takes 30–45 minutes."
    },
    "order_arrival": {
        "question": "When will my order arrive?",
        "answer": "Delivery typically takes 30–45 minutes."
    },
    "is_delivery_fast": {
        "question": "Is the delivery fast?",
        "answer": "Yes, delivery usually arrives within 30–45 minutes."
    },
    "order_tracking": {
        "question": "How can I track my order?",
        "answer": "You can track your order through the app or website using your order ID."
    },
    "track_order_status": {
        "question": "Where is my order?",
        "answer": "You can check your order status from the order tracking page."
    },
    "payment_methods": {
        "question": "What payment methods do you accept?",
        "answer": "We accept credit cards, debit cards, and cash on delivery."
    },
    "how_to_pay": {
        "question": "How do I pay?",
        "answer": "You can pay using credit/debit card or cash on delivery."
    },
    "return_policy": {
        "question": "What is your return policy?",
        "answer": "Returns are accepted within 14 days with proof of purchase."
    },
    "can_i_get_a_refund": {
        "question": "Can I get a refund?",
        "answer": "Yes, refunds are available for eligible returns."
    },
    "coupon_usage": {
        "question": "How can I use a coupon?",
        "answer": "You can apply a valid coupon during checkout in the app or website."
    },
    "do_you_have_discounts": {
        "question": "Do you offer discounts?",
        "answer": "Yes! We regularly have special offers, check the homepage for the latest deals."
    },
    "opening_hours": {
        "question": "What are your opening hours?",
        "answer": "We are open from 9 AM to 11 PM every day."
    },
    "delivery_area": {
        "question": "Do you deliver to my area?",
        "answer": "We deliver to most areas in the city. Enter your location during checkout to confirm."
    },
    "customer_support": {
        "question": "How can I contact customer support?",
        "answer": "You can reach us via live chat, phone, or email from the Contact Us page."
    },
    "what_is_a_mystery_bag": {
        "question": "What is a mystery bag?",
        "answer": "A mystery bag is a surprise assortment of unsold food offered at a discounted price by our vendor partners to help reduce food waste."
    },
    "how_does_mystery_bag_work": {
        "question": "How does the mystery bag work?",
        "answer": "You purchase a mystery bag from a vendor, and at pickup time, you receive a surprise selection of food items they had left over for the day."
    },
    "why_is_food_discounted": {
        "question": "Why is the food discounted?",
        "answer": "The food is still fresh but unsold. Vendors offer it at reduced prices to minimize food waste and make quality meals more accessible."
    },
    "is_food_fresh": {
        "question": "Is the food in mystery bags fresh?",
        "answer": "Yes, all food in mystery bags is safe to eat and comes from the same daily-prepared meals that vendors sell during business hours."
    },
    "pickup_time": {
        "question": "When can I pick up my mystery bag?",
        "answer": "Each vendor sets their own pickup window, usually near their closing time. You'll see the exact time when you place your order."
    },
    "can_i_choose_items": {
        "question": "Can I choose what's in the mystery bag?",
        "answer": "No — the mystery is part of the experience! But vendors ensure a fair and delicious mix of items."
    },
    "allergy_info": {
        "question": "What if I have food allergies?",
        "answer": "Please contact the vendor directly through the app before ordering. Some vendors may not be able to accommodate allergies due to the surprise nature of mystery bags."
    },
    "vendor_partners": {
        "question": "Who are your vendor partners?",
        "answer": "We partner with local restaurants, cafes, and bakeries that are committed to reducing food waste and offering quality meals to the community."
    },
    "sustainability_goal": {
        "question": "How does SustainGo support sustainability?",
        "answer": "By connecting customers with unsold meals, SustainGo helps reduce food waste and supports a more sustainable local food ecosystem."
    },
    "is_mystery_bag_safe": {
        "question": "Is the mystery bag safe to eat?",
        "answer": "Yes! All food follows safety standards and is sold within safe consumption timeframes as determined by each vendor."
    },
    "how_to_cancel_order": {
        "question": "Can I cancel my mystery bag order?",
        "answer": "Mystery bag orders are final due to the nature of food prep and discount pricing. Please only order if you're sure you can pick it up."
    },
    "how_to_rate_vendor": {
        "question": "How can I rate a vendor?",
        "answer": "After pickup, you'll be prompted in the app to rate your experience and provide feedback."
    },
    "sold_out": {
        "question": "Why do mystery bags sell out quickly?",
        "answer": "Since vendors only have a limited amount of surplus food, bags are first-come, first-served. Check back regularly or set alerts for your favorites!"
    }
}

@app.get("/faq/{question_key}")
async def get_faq_answer(question_key: str) -> Dict[str, Any]:
    if question_key in faqs:
        return faqs[question_key]
    return {
        "question": question_key,
        "answer": "I'm sorry, I don't have an answer to that question yet."
    }

@app.get("/faqs")
async def get_all_faqs() -> List[Dict[str, Any]]:
    return list(faqs.values())

@app.get("/ask")
async def ask_question(
    question: str = Query(..., description="Ask a question in your own words"),
    top_n: int = Query(3, description="Number of top matches to return"),
    min_score: float = Query(45.0, description="Minimum similarity score")
) -> Dict[str, Any]:
    matches = []

    for item in faqs.values():
        score = token_set_ratio(question, item["question"])
        matches.append({
            "question": item["question"],
            "answer": item["answer"],
            "score": round(score, 2)
        })

    matches.sort(key=lambda x: x["score"], reverse=True)
    top_matches = [m for m in matches if m["score"] >= min_score][:top_n]

    if not top_matches:
        log_unmatched_question(question)
        return {
            "your_question": question,
            "answer": "Sorry, I couldn’t find a close enough match.",
            "suggestions": []
        }

    return {
        "your_question": question,
        "suggestions": top_matches
    }

def log_unmatched_question(question: str):
    with open("unmatched_questions.log", "a", encoding="utf-8") as f:
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        f.write(f"[{timestamp}] {question}\n")
