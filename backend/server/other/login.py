from fastapi import FastAPI, HTTPException, Form
import json
from uuid import uuid4

app = FastAPI()

def load_user(file_path):
    with open(file_path, 'r') as file:
        data = json.load(file)
    return {user['username']: user['password'] for user in data['users']}

users = load_user('login_information.JSON')

@app.post("/login")
def login(username: str = Form(...), password: str = Form(...)):
    if username in users and users[username] == password:
        token = str(uuid4())
        return {"token": token}
    else:
        raise HTTPException(status_code=401, detail="Invalid username or password")
