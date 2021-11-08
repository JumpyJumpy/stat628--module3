import json
import numpy as np
import pandas as pd

business = pd.read_json("yelp_dataset/business.json", lines = True)
business = business[business["categories"].str.contains("Food", na = False)]
ids = business["business_id"].tolist()
business.describe()
business.to_csv("business")

review = pd.DataFrame()
with open("yelp_dataset/review.json", encoding = "utf-8") as f:
    for line in f:
        tmp = json.loads(line)
        if tmp["business_id"] in ids:
            review = review.append(tmp, ignore_index = True)
    #  review = json.load(f)  # does not work, MemoryError

review.to_csv("review.csv")
