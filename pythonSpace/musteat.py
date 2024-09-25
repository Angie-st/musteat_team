"""
author : 
Description :
Date : 
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
        host='127.0.0.1',
        user='root',
        password='qwer1234',
        db= 'python',
        charset='utf8'
    )
    return conn

@app.get('/select')
async def select():
    conn = connection()
    curs= conn.cursor()
    try:
        sql = "select seq, name, image, phone, long, lat, evaluate, favorite from address order by name"
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
    
@app.get('/insert')
async def insert(name: str=None, image: str=None, phone: str=None, long: str=None, lat: str=None, evaluate: str=None, favorite: str=None):
    conn = connection()
    curs= conn.cursor()

    try:
        sql = "insert into address(name, image, phone, long, lat, evaluate, favorite) values (%s,%s,%s,%s,%s,%s,%s)"
        curs.execute(sql, (name, image, phone, long, lat, evaluate, favorite))
        conn.commit()
        conn.close()
        return {'result' : 'OK'}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'result' : "Error"}

@app.get('/update')
async def update(seq: str=None, name: str=None, phone: str=None, long: str=None, lat: str=None, evaluate: str=None, favorite: str=None):
    conn = connection()
    curs= conn.cursor()

    try:
        sql = "update address set name=%s, phone=%s, long=%s, lat=%s, evaluate=%s, favorite=%s where seq = %s"
        curs.execute(sql, (name, phone, long, lat, evaluate, favorite, seq))
        conn.commit()
        conn.close()
        return {'result' : 'OK'}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'result' : "Error"}

@app.get('/update')
async def update(seq: str=None, name: str=None, image: str=None, phone: str=None, long: str=None, lat: str=None, evaluate: str=None, favorite: str=None):
    conn = connection()
    curs= conn.cursor()

    try:
        sql = "update address set name=%s, image =%s, phone=%s, long=%s, lat=%s, evaluate=%s, favorite=%s where seq = %s"
        curs.execute(sql, (name, image, phone, long, lat, evaluate, favorite, seq))
        conn.commit()
        conn.close()
        return {'result' : 'OK'}
    except Exception as e:
        conn.close()
        print('Error:', e)
        return {'result' : "Error"}

@app.post('/upload') # post 방식
async def upload_file(file: UploadFile=File(...)):
    try:
        file_path = os.path.join(UPLOAD_FOLDER, file.filename) # 업로드 폴더 경로에 파일네임을 만들겠다
        with open(file_path, "wb") as buffer:  # write binery
            shutil.copyfileobj(file.file, buffer)
        return {'result' : 'OK'}
    except Exception as e:
        print("Error:", e)
        return ({'result' : 'Error'})

@app.delete('/deleteFile/{file_name}')
async def delete_file(file_name: str):
    print("delete file :", file_name)
    print("--------------------------------")
    try:
        file_path = os.path.join(UPLOAD_FOLDER, file_name)
        if os.path.exists(file_path):
            os.remove(file_path)
        return {'result' : 'OK'}
    except Exception as e:
        print('result:' 'Error')
        return ({'result' : 'Error'})

@app.get('/delete')
async def delete(seq: int=None):
    conn = connection()
    curs = conn.cursor()

    try:
        sql ="delete from address where seq =%s"
        curs.execute(sql, (seq,))
        conn.commit()
        conn.close()
        return {'results' : 'OK'}
    except Exception as e:
        conn.close()
        print("Error :" , e)
        return {'results': 'Error'}
    
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)