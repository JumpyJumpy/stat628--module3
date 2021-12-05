import pandas as pd
import numpy as np
from sklearn.feature_extraction.text import TfidfTransformer
from sklearn.feature_extraction.text import CountVectorizer
from nltk.corpus import stopwords
import nltk

trivial_words_list = ["food", "coffee", "place"]


def tf_idf(text, trivial_words, language = "english"):
    stop_words = stopwords.words(language)
    vectorizer = CountVectorizer(stop_words = stop_words)
    frequency_matrix = TfidfTransformer().fit_transform(vectorizer.fit_transform(text))
    features = vectorizer.get_feature_names()
    frequency_array = frequency_matrix.toarray().sum(axis = 0)

    tags = nltk.pos_tag(features)
    words = [word for word, tag in tags if tag == "NN" and word not in trivial_words]
    frequency_series = pd.Series(frequency_array, index = features)
    frequency_series = frequency_series.loc[words].sort_values(ascending = False)[0:10]

    return frequency_series


pd.set_option("display.max_columns", None)
reviews = pd.read_csv("./data/filtered_reviews.csv")
business_id = set(reviews["business_id"].tolist())

key_features = pd.DataFrame()
for ids in business_id:
    row = pd.Series(ids, index = ["business_id"]).append(
        tf_idf(reviews.loc[reviews["business_id"] == ids, "text"], trivial_words = trivial_words_list).index.to_series(
            index = range(1, 11)))
    key_features = key_features.append(row, ignore_index = True)

key_features.to_csv("./data/tf_idf_words.csv")
