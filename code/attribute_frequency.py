import numpy as np
import pandas as pd

business = pd.read_csv("business.csv", index_col = 0)
business = business.loc[~business["attributes"].isna(), :]
business["attributes"] = [eval(attr) for attr in business["attributes"]]
attributes = [keys for i in range(len(business["attributes"])) for keys in business["attributes"].iloc[i]]

attributes = pd.Series(attributes)
print(attributes.value_counts())

counts = attributes.value_counts().to_dict()
keys = list(counts.keys())

business_flattened = pd.concat([business.iloc[:, 0], pd.DataFrame(np.nan, columns = keys, index = business.index)],
                               axis = 1)

for idx in business_flattened.index:
    for keys in business.loc[idx, "attributes"]:
        business_flattened.loc[idx, keys] = bool(business.loc[idx, "attributes"][keys])

business_flattened.to_csv("business_flattened.csv")
