import json
import numpy as np
import pandas as pd

with open("yelp_dataset/business.json", encoding = "utf-8") as f:
    business = json.load(f)


business = pd.read_json("yelp_dataset/business.json", lines = True)
