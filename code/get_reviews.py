import pandas as pd

# Finding the IDs of businesses that are cafes

business = pd.read_json("yelp_dataset/business.json", lines = True)
business = business[business["categories"].str.contains("Cafe", na = False)]
ids = business["business_id"].tolist()
business.to_csv("business.csv")

# Finding the reviews of businesses that are cafes

review = pd.DataFrame()
for chunk in pd.read_json("yelp_dataset/review.json", lines = True, chunksize = 25000, nrows = 1e7):
    review = pd.concat((review, chunk[chunk["business_id"].isin(ids)]))

review.to_csv("review.csv")
