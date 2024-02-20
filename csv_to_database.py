"""This file contains the code needed to store the csv files
in your SQL database"""

import pandas as pd
from sqlalchemy import create_engine

DATABASE_USER = "your_user_name"
DATABASE_PASSWORD = "your_password"
DATABASE_HOST = "localhost"
DATABASE_PORT = "3306"
DATABASE_NAME = "your_database_name"

# Create a database connection with SQLAlchemy (MySQL Server)
engine = create_engine(
    f"mysql+mysqlconnector://{DATABASE_USER}:{DATABASE_PASSWORD}@{DATABASE_HOST}:{DATABASE_PORT}/{DATABASE_NAME}"
)
conn = engine.connect()  # Connection to the database

# List of csv file names
files = ["athlete_events", "noc_regions"]

# Save data in your SQL database
# Your csv must be located in a 'data' folder
for file in files:
    df = pd.read_csv(f"data/{file}.csv")
    df.to_sql(file, con=conn, if_exists="replace", index=False)
