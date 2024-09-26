"""
author : 
Description :
Date : 
Usage : 
"""

from fastapi import APIRouter, File, UploadFile
from fastapi.responses import FileResponse
import pymysql
import os
import shutil

router = APIRouter()

UPLOAD_FOLDER = 'uploads' 
if not os.path.exists(UPLOAD_FOLDER): # 업로드 폴더가 없으면 폴더를 만들어라
    os.makedirs(UPLOAD_FOLDER)

def connection():
    conn = pymysql.connect(
        host='192.168.50.123',
        user='root',
        password='qwer1234',
        db= 'musteat',
        charset='utf8'
    )
    return conn

@router.get("/view/{file_name}")
async def get_file(file_name: str):
    file_path = os.path.join(UPLOAD_FOLDER, file_name)
    if os.path.exists(file_path):
        return FileResponse(path=file_path, filename=file_name)
    return {'results' : 'Error'}

@router.get('/insert')
async def insert(name: str=None, image: str=None, phone: str=None, long: str=None, lat: str=None, adddate: str=None,  favorite: str=None, comment: str=None, evaluate: str=None, user_id: str=None):
    conn = connection()
    curs= conn.cursor()

    try:
        sql = "insert into addmusteat(name, image, phone, longtitude, latitude, adddate, favorite, comment, evaluate, user_id) values (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"
        curs.execute(sql, (name, image, phone, long, lat, adddate, favorite, comment, evaluate, user_id))
        conn.commit()
        conn.close()
        return {'result' : 'OK'}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'result' : "Error"}

# post방식 업로드
@router.post('/upload') # post 방식
async def upload_file(file: UploadFile=File(...)):
    try:
        file_path = os.path.join(UPLOAD_FOLDER, file.filename) # 업로드 폴더 경로에 파일네임을 만들겠다
        with open(file_path, "wb") as buffer:  # write binery
            shutil.copyfileobj(file.file, buffer)
        return {'result' : 'OK'}
    except Exception as e:
        print("Error:", e)
        return ({'result' : 'Error'})
