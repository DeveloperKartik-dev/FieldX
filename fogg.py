from pathlib import Path

from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from pydantic import BaseModel
import mysql.connector
import hashlib
import re
from typing import Optional, List


app = FastAPI(
    title="FieldX API",
    description="Offline-first Land Survey and Inspection Backend",
    version="1.0.0"
)

def get_db():
    try:
        db = mysql.connector.connect(
            host="localhost",
            user="root",
            password="@Kartik00",
            database="central_govt",
            port=3306
        )

        return db

    except mysql.connector.Error as e:
        print("Database connection failed:", e)
        raise HTTPException(
            status_code=500,
            detail="Database connection failed."
        )


def hash_password(password: str):
    return hashlib.sha256(
        password.encode()
    ).hexdigest()


def valid_name(name: str):

    if not name:
        return False

    return bool(
        re.fullmatch(
            r"[A-Za-z]+(?: [A-Za-z]+)*",
            name
        )
    )


def valid_officer_id(officer_id: str):

    return (
        officer_id.isdigit()
        and len(officer_id) == 8
    )


def valid_mobile(mobile: str):

    if not mobile.isdigit():
        return False

    if len(mobile) != 10:
        return False

    if mobile[0] not in "6789":
        return False

    return True


def valid_survey_number(survey_number: str):

    if not survey_number:
        return False

    return bool(
        re.fullmatch(
            r"[A-Za-z0-9/-]+",
            survey_number
        )
    )


def valid_password(password: str):

    if len(password) < 8:
        return False

    if not re.search(r"[A-Z]", password):
        return False

    if not re.search(r"[a-z]", password):
        return False

    if not re.search(r"[0-9]", password):
        return False

    if not re.search(r"[^A-Za-z0-9]", password):
        return False

    return True


class SignupRequest(BaseModel):

    full_name: str
    officer_id: str
    mobile_no: str
    password: str
    confirm_password: str


class LoginRequest(BaseModel):

    officer_id: str
    password: str


class LandParcelRequest(BaseModel):

    survey_number: str
    owner_name: str
    area: float
    latitude: float
    longitude: float
    address: str


class SurveyRequest(BaseModel):

    parcel_id: int
    user_id: int


class SyncSurveyRequest(BaseModel):

    parcel_id: int
    user_id: int
    survey_date: Optional[str] = None
    status: str = "Synced"


class SyncRequest(BaseModel):

    surveys: List[SyncSurveyRequest]


@app.get("/")
def home():
    return FileResponse(Path(__file__).parent / "static" / "index.html")


@app.get("/health")
def health_check():

    db = None

    try:

        db = get_db()

        cursor = db.cursor()

        cursor.execute("SELECT 1")

        cursor.fetchone()

        cursor.close()
        db.close()

        return {
            "status": "online",
            "database": "connected"
        }

    except Exception:

        if db:
            db.close()

        return {
            "status": "online",
            "database": "disconnected"
        }


@app.post("/signup")
def signup(data: SignupRequest):

    db = None
    cursor = None

    try:


        full_name = data.full_name.strip()

        if not valid_name(full_name):

            raise HTTPException(
                status_code=400,
                detail="Invalid Full Name."
            )


        officer_id = data.officer_id.strip()

        if not valid_officer_id(officer_id):

            raise HTTPException(
                status_code=400,
                detail="Officer ID must contain exactly 8 digits."
            )


        mobile_no = data.mobile_no.strip()

        if not valid_mobile(mobile_no):

            raise HTTPException(
                status_code=400,
                detail="Invalid mobile number."
            )


        if not valid_password(data.password):

            raise HTTPException(
                status_code=400,
                detail=(
                    "Password must contain at least 8 characters, "
                    "one uppercase letter, one lowercase letter, "
                    "one number and one special character."
                )
            )


        if data.password != data.confirm_password:

            raise HTTPException(
                status_code=400,
                detail="Passwords do not match."
            )


        db = get_db()

        cursor = db.cursor()


        check_query = """
        SELECT user_id
        FROM users
        WHERE officer_id = %s
        OR mobile_no = %s
        """

        cursor.execute(
            check_query,
            (
                officer_id,
                mobile_no
            )
        )

        existing_user = cursor.fetchone()


        if existing_user:

            raise HTTPException(
                status_code=409,
                detail=(
                    "Officer ID or mobile number "
                    "already exists."
                )
            )


        password_hash = hash_password(
            data.password
        )


        insert_query = """
        INSERT INTO users
        (
            full_name,
            officer_id,
            mobile_no,
            password_hash,
            mobile_verified
        )
        VALUES
        (
            %s,
            %s,
            %s,
            %s,
            %s
        )
        """

        cursor.execute(
            insert_query,
            (
                full_name,
                officer_id,
                mobile_no,
                password_hash,
                True
            )
        )


        db.commit()


        user_id = cursor.lastrowid


        return {

            "success": True,

            "message": "Account created successfully.",

            "user": {

                "user_id": user_id,

                "full_name": full_name,

                "officer_id": officer_id,

                "mobile_no": mobile_no

            }

        }


    except HTTPException:

        if db:
            db.rollback()

        raise


    except mysql.connector.Error as e:

        if db:
            db.rollback()

        raise HTTPException(
            status_code=500,
            detail="Database error while creating account."
        )


    except Exception as e:

        if db:
            db.rollback()

        raise HTTPException(
            status_code=500,
            detail="Unexpected server error."
        )


    finally:

        if cursor:
            cursor.close()

        if db:
            db.close()


@app.post("/login")
def login(data: LoginRequest):

    db = None
    cursor = None

    try:

        officer_id = data.officer_id.strip()


        if not valid_officer_id(officer_id):

            raise HTTPException(
                status_code=400,
                detail="Officer ID must contain exactly 8 digits."
            )


        if not data.password:

            raise HTTPException(
                status_code=400,
                detail="Password cannot be empty."
            )


        password_hash = hash_password(
            data.password
        )


        db = get_db()

        cursor = db.cursor()


        login_query = """
        SELECT
            user_id,
            full_name,
            officer_id,
            mobile_no
        FROM users
        WHERE officer_id = %s
        AND password_hash = %s
        """


        cursor.execute(
            login_query,
            (
                officer_id,
                password_hash
            )
        )


        user = cursor.fetchone()


        if not user:

            raise HTTPException(
                status_code=401,
                detail="Invalid Officer ID or Password."
            )


        return {

            "success": True,

            "message": "Login successful.",

            "user": {

                "user_id": user[0],

                "full_name": user[1],

                "officer_id": user[2],

                "mobile_no": user[3]

            }

        }


    except HTTPException:

        raise


    except mysql.connector.Error:

        raise HTTPException(
            status_code=500,
            detail="Database error during login."
        )


    except Exception:

        raise HTTPException(
            status_code=500,
            detail="Unexpected server error."
        )


    finally:

        if cursor:
            cursor.close()

        if db:
            db.close()


@app.post("/land-parcel")
def create_land_parcel(
    data: LandParcelRequest
):

    db = None
    cursor = None

    try:

        survey_number = data.survey_number.strip()

        if not valid_survey_number(
            survey_number
        ):

            raise HTTPException(
                status_code=400,
                detail="Invalid Khasra / Survey Number."
            )


        owner_name = data.owner_name.strip()

        if not valid_name(owner_name):

            raise HTTPException(
                status_code=400,
                detail="Invalid Owner Name."
            )


        if data.area <= 0:

            raise HTTPException(
                status_code=400,
                detail="Land area must be greater than 0."
            )


        if (
            data.latitude < -90
            or
            data.latitude > 90
        ):

            raise HTTPException(
                status_code=400,
                detail="Latitude must be between -90 and 90."
            )


        if (
            data.longitude < -180
            or
            data.longitude > 180
        ):

            raise HTTPException(
                status_code=400,
                detail="Longitude must be between -180 and 180."
            )


        address = data.address.strip()

        if not address:

            raise HTTPException(
                status_code=400,
                detail="Address cannot be empty."
            )


        db = get_db()

        cursor = db.cursor()


        check_query = """
        SELECT parcel_id
        FROM land_parcels
        WHERE survey_number = %s
        """


        cursor.execute(
            check_query,
            (survey_number,)
        )


        existing_parcel = cursor.fetchone()


        if existing_parcel:

            raise HTTPException(
                status_code=409,
                detail=(
                    "This Khasra / Survey Number "
                    "already exists."
                )
            )


        insert_query = """
        INSERT INTO land_parcels
        (
            survey_number,
            owner_name,
            area,
            latitude,
            longitude,
            address
        )
        VALUES
        (
            %s,
            %s,
            %s,
            %s,
            %s,
            %s
        )
        """


        cursor.execute(
            insert_query,
            (
                survey_number,
                owner_name,
                data.area,
                data.latitude,
                data.longitude,
                address
            )
        )


        db.commit()


        parcel_id = cursor.lastrowid


        return {

            "success": True,

            "message": "Land parcel created successfully.",

            "parcel": {

                "parcel_id": parcel_id,

                "survey_number": survey_number,

                "owner_name": owner_name,

                "area": data.area,

                "latitude": data.latitude,

                "longitude": data.longitude,

                "address": address

            }

        }


    except HTTPException:

        if db:
            db.rollback()

        raise


    except mysql.connector.Error:

        if db:
            db.rollback()

        raise HTTPException(
            status_code=500,
            detail="Database error while saving land parcel."
        )


    except Exception:

        if db:
            db.rollback()

        raise HTTPException(
            status_code=500,
            detail="Unexpected server error."
        )


    finally:

        if cursor:
            cursor.close()

        if db:
            db.close()


@app.get("/land-parcels")
def get_land_parcels():

    db = None
    cursor = None

    try:

        db = get_db()

        cursor = db.cursor()


        query = """
        SELECT
            parcel_id,
            survey_number,
            owner_name,
            area,
            latitude,
            longitude,
            address,
            created_at
        FROM land_parcels
        ORDER BY created_at DESC
        """


        cursor.execute(query)

        parcels = cursor.fetchall()


        result = []


        for parcel in parcels:

            result.append({

                "parcel_id": parcel[0],

                "survey_number": parcel[1],

                "owner_name": parcel[2],

                "area": float(parcel[3]),

                "latitude": float(parcel[4]),

                "longitude": float(parcel[5]),

                "address": parcel[6],

                "created_at": str(parcel[7])

            })


        return {

            "success": True,

            "count": len(result),

            "parcels": result

        }


    except mysql.connector.Error:

        raise HTTPException(
            status_code=500,
            detail="Database error while fetching parcels."
        )


    except Exception:

        raise HTTPException(
            status_code=500,
            detail="Unexpected server error."
        )


    finally:

        if cursor:
            cursor.close()

        if db:
            db.close()


@app.post("/survey")
def create_survey(
    data: SurveyRequest
):

    db = None
    cursor = None

    try:

        db = get_db()

        cursor = db.cursor()


        user_query = """
        SELECT user_id
        FROM users
        WHERE user_id = %s
        """


        cursor.execute(
            user_query,
            (data.user_id,)
        )


        user = cursor.fetchone()


        if not user:

            raise HTTPException(
                status_code=404,
                detail="Officer not found."
            )


        parcel_query = """
        SELECT parcel_id
        FROM land_parcels
        WHERE parcel_id = %s
        """


        cursor.execute(
            parcel_query,
            (data.parcel_id,)
        )


        parcel = cursor.fetchone()


        if not parcel:

            raise HTTPException(
                status_code=404,
                detail="Land parcel not found."
            )


        insert_query = """
        INSERT INTO surveys
        (
            parcel_id,
            user_id,
            status
        )
        VALUES
        (
            %s,
            %s,
            %s
        )
        """


        cursor.execute(
            insert_query,
            (
                data.parcel_id,
                data.user_id,
                "Pending"
            )
        )


        db.commit()


        survey_id = cursor.lastrowid


        return {

            "success": True,

            "message": "Survey created successfully.",

            "survey": {

                "survey_id": survey_id,

                "parcel_id": data.parcel_id,

                "user_id": data.user_id,

                "status": "Pending"

            }

        }


    except HTTPException:

        if db:
            db.rollback()

        raise


    except mysql.connector.Error:

        if db:
            db.rollback()

        raise HTTPException(
            status_code=500,
            detail="Database error while creating survey."
        )


    except Exception:

        if db:
            db.rollback()

        raise HTTPException(
            status_code=500,
            detail="Unexpected server error."
        )


    finally:

        if cursor:
            cursor.close()

        if db:
            db.close()


@app.post("/sync")
def sync_data(
    data: SyncRequest
):

    db = None
    cursor = None

    synced = []

    failed = []


    try:

        db = get_db()

        cursor = db.cursor()


        for survey in data.surveys:

            try:

                cursor.execute(
                    """
                    SELECT user_id
                    FROM users
                    WHERE user_id = %s
                    """,
                    (survey.user_id,)
                )


                user = cursor.fetchone()


                if not user:

                    failed.append({

                        "parcel_id": survey.parcel_id,

                        "reason": "Officer not found."

                    })

                    continue

                cursor.execute(
                    """
                    SELECT parcel_id
                    FROM land_parcels
                    WHERE parcel_id = %s
                    """,
                    (survey.parcel_id,)
                )


                parcel = cursor.fetchone()


                if not parcel:

                    failed.append({

                        "parcel_id": survey.parcel_id,

                        "reason": "Parcel not found."

                    })

                    continue


                insert_query = """
                INSERT INTO surveys
                (
                    parcel_id,
                    user_id,
                    status,
                    sync_time
                )
                VALUES
                (
                    %s,
                    %s,
                    %s,
                    NOW()
                )
                """


                cursor.execute(
                    insert_query,
                    (
                        survey.parcel_id,
                        survey.user_id,
                        "Synced"
                    )
                )


                survey_id = cursor.lastrowid


                sync_query = """
                INSERT INTO sync_logs
                (
                    survey_id,
                    sync_status,
                    sync_attempt,
                    synced_at
                )
                VALUES
                (
                    %s,
                    %s,
                    %s,
                    NOW()
                )
                """


                cursor.execute(
                    sync_query,
                    (
                        survey_id,
                        "Success",
                        1
                    )
                )


                synced.append({

                    "parcel_id": survey.parcel_id,

                    "survey_id": survey_id,

                    "status": "Synced"

                })


            except Exception as e:

                failed.append({

                    "parcel_id": survey.parcel_id,

                    "reason": str(e)

                })


        db.commit()


        return {

            "success": True,

            "message": "Sync process completed.",

            "synced_count": len(synced),

            "failed_count": len(failed),

            "synced": synced,

            "failed": failed

        }


    except mysql.connector.Error:

        if db:
            db.rollback()

        raise HTTPException(
            status_code=500,
            detail="Database error during synchronization."
        )


    except Exception:

        if db:
            db.rollback()

        raise HTTPException(
            status_code=500,
            detail="Unexpected error during synchronization."
        )


    finally:

        if cursor:
            cursor.close()

        if db:
            db.close()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("fogg:app", host="0.0.0.0", port=8000, reload=True)