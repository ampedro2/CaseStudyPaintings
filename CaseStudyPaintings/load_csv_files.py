import pandas as pd
from sqlalchemy import create_engine

# Establish a connection to a PostgreSQL database named 'painting' using SQLAlchemy

conn_string = 'postgresql://postgres:admin@localhost/painting'
db = create_engine(conn_string)
conn = db.connect()

# List of filenames (without extension) containing CSV data to be imported into the database

files = ['artist', 'canvas_size', 'image_link', 'museum_hours', 'museum', 'product_size', 'subject', 'work']

# Loop through each file in the list

for file in files:

    # Read the CSV file into a Pandas DataFrame

    df = pd.read_csv(f'\Users\Pedro\Desktop\csvs\{file}.csv')
    
    # Write the DataFrame to the corresponding database table
    # if_exists='replace' means that if the table already exists in the database, it will be replaced
    # index=False means not to write the DataFrame index to the database

    df.to_sql(file, con=conn, if_exists='replace', index=False)

    