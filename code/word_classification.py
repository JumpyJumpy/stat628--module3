import re
import string
import nltk
import pandas as pd
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
from nltk.tokenize import word_tokenize

reviews = pd.read_csv("./data/filtered_reviews.csv")

try:
    stop_words = stopwords.words("english")
except LookupError:
    nltk.download('stopwords')
    nltk.download('punkt')
    nltk.download('wordnet')
    nltk.download('averaged_perceptron_tagger')

reviews["text"] = reviews["text"].str.lower()
reviews["text"] = reviews["text"].str.replace(pat = "n\'t ", repl = "not")
reviews["text"] = reviews["text"].str.replace(pat = "not ", repl = "not_")
reviews["text"] = reviews["text"].apply(word_tokenize)


def process_text_with_tag(text, tags):
    review_text = [word.translate(str.maketrans('', '', string.punctuation))
                   for word in text if not re.match(r'not_.*', word)]
    review_text = [word for word in review_text if word.isalpha()]
    review_text = [word for word in review_text if word not in stop_words]
    review_text = [WordNetLemmatizer().lemmatize(word) for word in review_text]
    review_text = [word for word, tag in nltk.pos_tag(review_text) if tag == tags]
    return review_text


reviews["adj"] = reviews["text"].apply(process_text_with_tag, tags = "JJ")
reviews["adj"] = reviews["text"].apply(process_text_with_tag, tags = "NN")

reviews.to_csv("./data/reviews_tokenized.csv")
