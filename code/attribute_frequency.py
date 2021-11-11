import numpy as np
import pandas as pd
import ast

# bug found
# debugging
# not working
business = pd.read_csv("business.csv", index_col = 0)
business = business.loc[~(pd.isna(business["attributes"])), :]

business["attributes"] = [ast.literal_eval(attr) for attr in business["attributes"]]
attributes = [keys for i in range(len(business["attributes"])) for keys in business["attributes"].iloc[i]]


attributes = pd.Series(attributes)
print(attributes.value_counts())

attributes_counts = attributes.value_counts().to_dict()
attributes_keys = list(attributes_counts.keys())

business_flattened = \
    pd.concat([business.iloc[:, 0], pd.DataFrame(np.nan, columns = attributes_keys, index = business.index)], axis = 1)


for idx in business_flattened.index.to_list():
    for keys in business.loc[idx, "attributes"]:
        print(business.loc[idx, "attributes"][keys])
        print(idx, keys)
        #business_flattened.loc[idx, keys] = business.loc[idx, "attributes"][keys]

business_flattened.to_csv("business_flattened.csv")
