import numpy as np
import pandas as pd
import json
import ast

business = pd.read_csv("business.csv")
nested_attributes = [ast.literal_eval(i) for i in business["attributes"].to_list() if i is not np.nan]
attributes = [keys for j in range(len(nested_attributes)) for keys in nested_attributes[j]]

attributes = pd.Series(attributes)
print(attributes.value_counts())

counts = attributes.value_counts().to_dict()
keys = list(counts.keys())

