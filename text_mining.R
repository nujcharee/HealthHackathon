# Input load. Please do not change #
`dataset` = read.csv('C:/Users/nhaswell/REditorWrapper_e413f988-999d-4936-95cd-78d2084e6a89/input_df_abfc6493-86a1-4836-b366-3dd8854a5b68.csv', check.names = FALSE, encoding = "UTF-8", blank.lines.skip = FALSE);
# Original Script. Please update your script content here and once completed copy below section back to the original editing window #
##############################


library(tidyverse)
library(tidytext)

dataset = dataset %>% mutate(id = row_number())

foi_title <- dataset %>% 
  unnest_tokens(word, title) %>% 
  anti_join(stop_words)

foi_desc <- dataset %>% 
  unnest_tokens(word, desc) %>% 
  anti_join(stop_words)


foi_title

my_stopwords <- tibble(word = c(as.character(1:10), 
                                "freedom", "information", "request", "dear", "mr", "mrs", "miss", "foi", "response", "attached")
                       , lexicon = as.character("custom"))

custom_stopwords = rbind(stop_words, my_stopwords)

foi_title <- foi_title %>% 
  anti_join(my_stopwords)


foi_desc <- foi_desc %>% 
  anti_join(my_stopwords)


foi_bigrams <- dataset %>%
  unnest_tokens(bigram, title, token = "ngrams", n = 2)


foi_bigrams %>% select(id, bigram)


bigrams_separated <- foi_bigrams %>%
  separate(bigram, c("word1", "word2"), sep = " ")

bigrams_filtered <- bigrams_separated %>%
  filter(!word1 %in% custom_stopwords$word) %>%
  filter(!word2 %in% custom_stopwords$word)

# new bigram counts:
bigram_counts <- bigrams_filtered %>% 
  count(word1, word2, sort = TRUE)

bigram_counts


bigrams_united <- bigrams_filtered %>%
  unite(bigram, word1, word2, sep = " ")

bigrams_united


bigram_graph <- bigram_counts %>%
  filter(n > 4) %>%
  graph_from_data_frame()

bigram_graph


# description -------------------------------------------------------------

foi_bigrams <- dataset %>%
  unnest_tokens(bigram, desc, token = "ngrams", n = 2)


foi_bigrams %>% select(id, bigram)


bigrams_separated <- foi_bigrams %>%
  separate(bigram, c("word1", "word2"), sep = " ")

bigrams_filtered <- bigrams_separated %>%
  filter(!word1 %in% custom_stopwords$word) %>%
  filter(!word2 %in% custom_stopwords$word)

# new bigram counts:
bigram_counts <- bigrams_filtered %>% 
  count(word1, word2, sort = TRUE)

bigram_counts


bigrams_united <- bigrams_filtered %>%
  unite(bigram, word1, word2, sep = " ")

bigrams_united


bigram_graph <- bigram_counts %>%
  filter(n > 4) %>%
  graph_from_data_frame()

bigram_graph







library(ggraph)
set.seed(2017)

ggraph(bigram_graph, layout = "fr") +
  geom_edge_link() +
  geom_node_point() +
  geom_node_text(aes(label = name), vjust = 1, hjust = 1)




set.seed(2020)

a <- grid::arrow(type = "closed", length = unit(.15, "inches"))

ggraph(bigram_graph, layout = "fr") +
  geom_edge_link(aes(edge_alpha = n), show.legend = FALSE,
                 arrow = a, end_cap = circle(.07, 'inches')) +
  geom_node_point(color = "lightblue", size = 5) +
  geom_node_text(aes(label = name), vjust = 1, hjust = 1) +
  theme_void()

library(stringr)

library(widyr)

title_word_pairs <- dataset %>% 
  pairwise_count(title, sort = TRUE, upper = FALSE)

title_word_pairs




# split into words
by_chapter_word <- dataset %>%
  unnest_tokens(word, desc)

# customer stop words
custom = c("freedom", "information", "request", "dear", "mr", "mrs", "miss", "foi", "response", "attached")


# find document-word counts
word_counts <- by_chapter_word %>%
  anti_join(stop_words) %>%
  count(`for`, word, sort = TRUE) %>%
  ungroup()

word_counts


chapters_dtm <- word_counts %>%
  cast_dtm(`for`, word, n)

chapters_dtm


library(topicmodels)
chapters_lda <- LDA(chapters_dtm, k = 4, control = list(seed = 1234))
chapters_lda


chapter_topics <- tidy(chapters_lda, matrix = "beta")
chapter_topics

top_terms <- chapter_topics %>%
  group_by(topic) %>%
  top_n(15, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

top_terms %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_y_reordered()
