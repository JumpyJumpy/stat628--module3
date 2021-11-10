import numpy as np
import pandas as pd
import json
import ast

business = pd.read_csv("business.csv")
nested_attributes = [ast.literal_eval(i) for i in business["attributes"].to_list() if i is not np.nan]

attributes = []
for i in range(len(nested_attributes)):
    for keys in nested_attributes[i]:
        attributes.append(keys)

attributes = pd.Series(attributes)
print(attributes.value_counts())
