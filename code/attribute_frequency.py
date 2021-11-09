import numpy as np
import pandas as pd
import json
import ast

business = pd.read_csv("business.csv")
business_attributes = [ast.literal_eval(i) for i in business["attributes"].to_list() if i is not np.nan]
