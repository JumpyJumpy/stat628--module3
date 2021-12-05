import pandas as pd
from sklearn.feature_extraction.text import TfidfTransformer
from sklearn.feature_extraction.text import CountVectorizer


def tf_idf(text):
    vectorizer = CountVectorizer(min_df = 20)
    frequency_matrix = TfidfTransformer().fit_transform(vectorizer.fit_transform(text))
    features = vectorizer.get_feature_names()
    frequency_array = frequency_matrix.toarray().sum(axis = 0)

    words = pd.Series(frequency_array, index = features).sort_values(ascending = False)
    return words


reviews = pd.read_csv("./data/reviews_tokenized.csv", index_col = 0)
