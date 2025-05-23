from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from datetime import datetime, timedelta
import smtplib
import random
import os
from dotenv import load_dotenv

load_dotenv()
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Update for production
    allow_methods=["*"],
    allow_headers=["*"],
)

# In-memory storage
otp_storage = {}

class EmailRequest(BaseModel):
    email: str

class OTPVerification(BaseModel):
    email: str
    otp: str

def send_otp_email(email: str, otp: str) -> bool:
    try:
        with smtplib.SMTP(os.getenv("SMTP_SERVER"), int(os.getenv("SMTP_PORT"))) as server:
            server.starttls()
            server.login(os.getenv("EMAIL_SENDER"), os.getenv("EMAIL_PASSWORD"))
            message = f"Subject: Your OTP Code\n\nYour verification code is: {otp}"
            server.sendmail(os.getenv("EMAIL_SENDER"), email, message)
        return True
    except Exception as e:
        print(f"Email error: {e}")
        return False

@app.post("/request-otp")
def request_otp(request: EmailRequest):
    email = request.email
    otp = str(random.randint(100000, 999999))
    expires_at = datetime.now() + timedelta(minutes=5)

    if not send_otp_email(email, otp):
        raise HTTPException(status_code=500, detail="Failed to send OTP email")

    otp_storage[email] = {
        "otp": otp,
        "expires_at": expires_at.timestamp()
    }
    return {"message": "OTP sent successfully", "email": email}

@app.post("/verify-otp")
def verify_otp(request: OTPVerification):
    email = request.email
    user_otp = request.otp

    stored_data = otp_storage.get(email)
    if not stored_data:
        raise HTTPException(status_code=404, detail="OTP not found or expired")

    if datetime.now().timestamp() > stored_data['expires_at']:
        del otp_storage[email]
        raise HTTPException(status_code=400, detail="OTP expired")

    if user_otp == stored_data['otp']:
        del otp_storage[email]
        return {"message": "OTP verified successfully"}
    
    raise HTTPException(status_code=400, detail="Invalid OTP")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=10000)
