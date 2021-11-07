import json
import numpy as np
import pandas as pd

business = pd.read_json("yelp_dataset/business.json", lines = True)

with open("yelp_dataset/review.json", encoding = "utf-8") as f:
    review = json.load(f)  # does not work, MemoryError
