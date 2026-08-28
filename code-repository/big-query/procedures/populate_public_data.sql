INSERT INTO `kirtuos-poc.poc_dataset.shakespeare_sample` (word, word_count, corpus, corpus_date)
SELECT word, word_count, corpus, corpus_date 
FROM `bigquery-public-data.samples.shakespeare` 
LIMIT 1000;