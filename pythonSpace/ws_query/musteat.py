"""
author : ppochcco
Description : query 홈 화면
Date : 0926
Usage : 
"""

from fastapi import FastAPI, File, UploadFile
from fastapi.responses import FileResponse
import pymysql
import os
import shutil

app = FastAPI()

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

@app.get('/select')
async def select():
    conn = connection()
    curs= conn.cursor()
    try:
        sql = "select * from addmusteat"
        curs.execute(sql)
        rows = curs.fetchall()
        conn.close()
        print(rows)
        return {'results' : rows}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'result' : "Error"}

@app.get('/select_favorite')
async def select():
    conn = connection()
    curs= conn.cursor()
    try:
        sql = "select * from addmusteat where favorite=1"
        curs.execute(sql)
        rows = curs.fetchall()
        conn.close()
        print(rows)
        return {'results' : rows}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'result' : "Error"}
    
@app.get("/view/{file_name}")
async def get_file(file_name: str):
    file_path = os.path.join(UPLOAD_FOLDER, file_name)
    if os.path.exists(file_path):
        return FileResponse(path=file_path, filename=file_name)
    return {'results' : 'Error'}
    

@app.post('/upload') # post 방식
async def upload_file(file: UploadFile=File(...)):
    try:
        file_path = os.path.join(UPLOAD_FOLDER, file.filename) # 업로드 폴더 경로에 파일네임을 만들겠다
        with open(file_path, "wb") as buffer:  # wb: write binary
            shutil.copyfileobj(file.file, buffer)   # buffer가 destination
        return {'result' : 'OK'}
    except Exception as e:
        print("Error:", e)
        return ({'result' : 'Error'})

@app.delete('/deleteFile/{file_name}')
async def delete_file(file_name: str):
    # print("delete file :", file_name)
    try:
        file_path = os.path.join(UPLOAD_FOLDER, file_name)
        if os.path.exists(file_path):
            os.remove(file_path)
        return {'result' : 'OK'}
    except Exception as e:
        print('Error:', e)
        return {'result' : 'Error'}

@app.get('/delete')
async def delete(seq: int=None):
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
        print("Error :" , e)
        return {'results': 'Error'}
    
    # Update favorite 추가

    
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)