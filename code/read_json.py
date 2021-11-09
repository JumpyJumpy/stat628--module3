import json
import numpy as np
import pandas as pd

business = pd.read_json("yelp_dataset/business.json", lines = True)
business = business[business["categories"].str.contains("Cafe", na = False)]
ids = business["business_id"].tolist()
business.to_csv("business.csv")

review = pd.DataFrame()
review_json = []
n = 0
with open("yelp_dataset/review.json", encoding = "utf-8") as f:
    for line in f:
        tmp = json.loads(line)
        print(f"Read {n} lines")
        n += 1
        if tmp["business_id"] in ids:
            review = review.append(tmp, ignore_index = True)


review.to_csv("review.csv")
