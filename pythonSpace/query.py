"""
author : ppochcco
Description : query 홈 화면
Date : 0926
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

@router.get('/select')
async def select(user_id: str=None):
    conn = connection()
    curs= conn.cursor()
    try:
        sql = "select * from addmusteat where user_id=%s"
        curs.execute(sql, (user_id,))
        rows = curs.fetchall()
        conn.close()
        print(rows)
        return {'results' : rows}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'results' : "Error"}

@router.get('/select_favorite')
async def select(user_id: str=None):
    conn = connection()
    curs= conn.cursor()
    try:
        sql = "select * from addmusteat where user_id=%s and favorite=1"
        curs.execute(sql, (user_id,))
        rows = curs.fetchall()
        conn.close()
        print(rows)
        return {'results' : rows}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'results' : "Error"}
    
@router.get("/view/{file_name}")
async def get_file(file_name: str):
    file_path = os.path.join(UPLOAD_FOLDER, file_name)
    if os.path.exists(file_path):
        return FileResponse(path=file_path, filename=file_name)
    return {'results' : 'Error'}
    

@router.post('/upload') # post 방식
async def upload_file(file: UploadFile=File(...)):
    try:
        file_path = os.path.join(UPLOAD_FOLDER, file.filename) # 업로드 폴더 경로에 파일네임을 만들겠다
        with open(file_path, "wb") as buffer:  # wb: write binary
            shutil.copyfileobj(file.file, buffer)   # buffer가 destination
        return {'results' : 'OK'}
    except Exception as e:
        print("Error:", e)
        return ({'results' : 'Error'})

# 이미지 폴더에서 삭제된 목록의 이미지 삭제
@router.delete('/deleteFile/{file_name}')
async def delete_file(file_name: str):
    # print("delete file :", file_name) 
    try:
        file_path = os.path.join(UPLOAD_FOLDER, file_name)
        if os.path.exists(file_path):
            os.remove(file_path)
        return {'results' : 'OK'}
    except Exception as e:
        print('Error:', e)
        return {'results' : 'Error'}

@router.get('/delete')
async def delete(seq: str=None):
    conn = connection()
    curs = conn.cursor()

    try:
        sql ="delete from addmusteat where seq = %s"
        curs.execute(sql, (seq,))
        conn.commit()
        conn.close()
        return {'results' : 'OK'}
    except Exception as e:
        conn.close()
        print("Error :", e)
        return {'results': 'Error'}
    
    # Update favorite 추가
@router.get('/update_favorite')
async def insert(seq: int=None, favorite: int=None, user_id: str=None):
    conn = connection()
    curs= conn.cursor()
    try:
        sql = "update addmusteat set favorite = %s where seq = %s and user_id = %s"
        curs.execute(sql, (favorite,seq, user_id))
        conn.commit()
        conn.close()
        return {'results' : 'OK'}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'results' : "Error"}    