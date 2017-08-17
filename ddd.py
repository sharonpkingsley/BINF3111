#!/usr/bin/python
import sys
import pandas as pd
from sqlalchemy import create_engine
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

df1 = pd.read_csv("/Users/Vivian/desktop/dummy_files.csv")
#print(df1)
#/Users/Vivian/Library/Application Support/Postgres/var-9.6
engine = create_engine('postgresql://Vivian:password@localhost/myDrugDatabase', echo=True)

#print df1.columns
#remember to select * from "table_name";
with engine.connect() as conn, conn.begin():
    df1.to_sql('Table1', conn, if_exists='replace')
    