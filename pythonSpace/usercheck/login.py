"""
author      :
Description :
Date        :
Usage       :
"""
from fastapi import FastAPI
import pymysql

app = FastAPI()

def connect():
    conn = pymysql.connect(
        host='192.168.50.123',
        user='root',
        password='qwer1234',
        db='musteat',
        charset='utf8'
    )
    return conn

@app.get("/checkuser")
async def checkuser(password: str=None, id: str=None):
    print(password, id)
    conn=connect()
    curs=conn.cursor()
    try:
        sql="select count(*) from user where id=%s and password=%s"
        curs.execute(sql,(id, password))
        conn.commit()
        user_check = curs.fetchone()[0]
        conn.close()
        return{'result': user_check}
    except Exception as e:
        conn.close()
        print("Error",e)
        return{'result':'Error'}

@app.get("/checkuserid")
async def checkuser(id: str=None):
    print(id)
    conn=connect()
    curs=conn.cursor()
    try:
        sql="select count(*) from user where id=%s"
        curs.execute(sql,(id))
        conn.commit()
        user_check = curs.fetchone()[0]
        conn.close()
        return{'result': user_check}
    except Exception as e:
        conn.close()
        print("Error",e)
        return{'result':'Error'}


@app.get("/insertuserid")
async def insertuser(id: str=None, password: str=None, name: str=None, phone: str=None):
    conn=connect()
    curs=conn.cursor()

    try:
        sql="insert into user(id, password, name, phone) values (%s,%s,%s,%s)"
        curs.execute(sql,(id,password,name,phone))
        conn.commit()
        conn.close()
        return{'result':'OK'}
    except Exception as e:
        conn.close()
        print("Error",e)
        return{'result':'Error'}


if __name__=="__main__":
    import uvicorn
    uvicorn.run(app,host="127.0.0.1", port=8000)
