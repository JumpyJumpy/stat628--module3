# STAT 628 Module 3
Yelp Data Project

## Objective
The objective of the project is to give analytic discussion on the café 
businesses on Yelp by using data provided by Yelp, and to suggest practical and 
specific action plans for business owners to improve their business.

## Data


The raw datasets are in the format of `.json` and they are too large to be uploaded to GitHub, but they can be accessed at [https://uwmadison.box.com/s/8864nymigxb3r4g2u2o5s74xspsutlrd](https://uwmadison.box.com/s/8864nymigxb3r4g2u2o5s74xspsutlrd).
The [data]() folder contains 6 related dataset.
`business.csv` is part of the original data; `Attributes_advice.csv` is the data after splitting the attributes.
`tf_idf_words.csv` and `word_list.csv` contains the words selected by td-idf and words we care about selected from the tf-idf results.
`attributes.suggestions.csv` and  `suggestions.csv` contains our final general suggestions based on attributes and specific suggestions based on reviews.


## Code
All relavant codes are in [code]() folder. Codes are written in `Python` and `R`. 
- `attribute_frequency.py` read the `business.json` into a dataframe, flattened all nested columns, and write it to a `.csv` file.  
- `attributes_analysis.R` 
- `distribution.R`
- `get_reviews.py`
- `read_json.py`
- `tf_idf.py`
- `word_classification.py`
- `word_t_test.R`

## Image
There are two subfolders inside image folder
The [EDA](https://github.com/JumpyJumpy/stat628-module3/tree/master/image/EDA) folder contains the images produced about the distribution of specific word in the first presentation
The [Attribute Analysis](https://github.com/JumpyJumpy/stat628-module3/tree/master/image/Attribute%20Analysis) folder contains the images produced about the histograms comparing scaled ratings

## Authors
If you have any questions please contact:  
- Shubo Lin: slin268@wisc.edu  
- Hengrui Qu: hengrui.qu@wisc.edu  
- Nilay Varshney: nvarshney2@wisc.edu  
- Tianyue Luo: tluo48@wisc.edu  

