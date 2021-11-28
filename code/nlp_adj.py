import numpy as np
import pandas as pd
import re
import nltk
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords

reviews = pd.read_csv("./data/filtered_reviews.csv")

try:
    stop_words = stopwords.words("english")
except LookupError:
    nltk.download(stopwords)


reviews["text"] = reviews["text"].str.lower()
reviews["text"] = reviews["text"].str.replace(pat = "n\'t ", repl = "not")
reviews["text"] = reviews["text"].str.replace(pat = "not ", repl = "not_")

