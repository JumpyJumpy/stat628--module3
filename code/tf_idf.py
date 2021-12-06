import pandas as pd
import numpy as np
from sklearn.feature_extraction.text import TfidfTransformer
from sklearn.feature_extraction.text import CountVectorizer
from nltk.corpus import stopwords
import nltk

trivial_words_list = ["food", "everything", "creature", "onto", "return", "improvement", "house", "place", "ice",
                      "phone", "sunday", "fashion", "experience", "groupon", "bit", "gas", "selection", "store", "info",
                      "car", "station", "everybody", "time", "area", "star", "eat", "mrs", "restaurant", "shop", "get",
                      "enjoy", "spot", "get", "go", "hark", "school", "market", "love", "section", "cm", "austin",
                      "sweet", "rj", "cambridge", "gourmet", "neighborhood", "kind", "work", "order", "try", "balq",
                      "boston", "go", "course", "alex", "nemesis", "alsace", "decatur", "head", "capital", "account",
                      "card", "bank", "super", "hair", "addition", "home", "hospital", "worth", "office", "covid",
                      "space", "sub", "subs", "favorite", "week", "village", "produce", "dragon", "hash", "quick",
                      "party", "street", "stop", "earl", "nice", "foot"]
word_list = pd.read_csv("./data/word_list.csv").iloc[:, 1].tolist()




def tf_idf(text, words, language = "english"):
    stop_words = stopwords.words(language)
    vectorizer = CountVectorizer(stop_words = stop_words)
    frequency_matrix = TfidfTransformer().fit_transform(vectorizer.fit_transform(text))
    features = vectorizer.get_feature_names()
    frequency_array = frequency_matrix.toarray().sum(axis = 0)

    tags = nltk.pos_tag(features)
    words = [word for word, tag in tags if tag == "NN" and word in words]
    frequency_series = pd.Series(frequency_array, index = features)
    frequency_series = frequency_series.loc[words].sort_values(ascending = False)[0:2]

    return frequency_series


pd.set_option("display.max_columns", None)
reviews = pd.read_csv("./data/filtered_reviews.csv")
business_id = set(reviews["business_id"].tolist())

key_features = pd.DataFrame()
for ids in business_id:
    row = pd.Series(ids, index = ["business_id"]).append(
        tf_idf(reviews.loc[reviews["business_id"] == ids, "text"], words = word_list).index.to_series(
            index = range(1, 3)))
    key_features = key_features.append(row, ignore_index = True)

key_features.to_csv("./data/tf_idf_words.csv")
