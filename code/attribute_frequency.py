import numpy as np
import pandas as pd
import ast

business = pd.read_csv("business.csv", index_col = 0)
business = business.loc[~(pd.isna(business["attributes"])), :]

business["attributes"] = business["attributes"].apply(ast.literal_eval)
attributes = [keys for i in range(len(business["attributes"])) for keys in business["attributes"].iloc[i]]
business = business.join(pd.json_normalize(business["attributes"]))

nested_column = ["BusinessParking", "Ambience"]
for col in nested_column:
    for idx in business.index:
        if type(business.loc[idx, col]) is str:
            business.loc[idx, col] = [ast.literal_eval(business.loc[idx, col])]
    col_flattened = pd.json_normalize(business[col])
    col_flattened.index = business.index
    business = business.join(col_flattened)

attributes = pd.Series(attributes)
print(attributes.value_counts())

attributes_counts = attributes.value_counts().to_dict()
attributes_keys = list(attributes_counts.keys())

business.to_csv("business_flattened.csv")

