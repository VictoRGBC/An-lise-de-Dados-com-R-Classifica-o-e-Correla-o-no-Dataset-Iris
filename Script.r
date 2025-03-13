# Carregar as bibliotecas necessárias
library(ggplot2)  # Para visualizações
library(caret)    # Para classificação e modelos
library(corrplot) # Para visualização da matriz de correlação

# 1. Importar o conjunto de dados
data(iris)

# 2. Análise Exploratória
# Visualizando as primeiras linhas do dataset
head(iris)

# Estatísticas descritivas
summary(iris)

# Função para visualizar a distribuição das variáveis
plot_distributions <- function(data) {
  # Gráfico de dispersão (scatter plot) para Sepal.Length vs Sepal.Width
  p1 <- ggplot(data, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
    geom_point(alpha = 0.7) +
    labs(title = "Dispersão: Sepal Length vs Sepal Width", x = "Sepal Length", y = "Sepal Width") +
    theme_minimal()
  
  # Gráfico de caixa (boxplot) para Sepal.Length por espécie
  p2 <- ggplot(data, aes(x = Species, y = Sepal.Length, fill = Species)) +
    geom_boxplot() +
    labs(title = "Distribuição do comprimento da Sépala por Espécie", x = "Espécie", y = "Comprimento da Sépala") +
    theme_minimal()
  
  # Exibir os gráficos
  print(p1)
  print(p2)
}

# Chamar a função para visualizar as distribuições
plot_distributions(iris)

# 3. Análise de Correlação
# Calculando a matriz de correlação para as variáveis numéricas
correlation_matrix <- cor(iris[, 1:4])  # Considerando as colunas numéricas apenas
print(correlation_matrix)

# Visualizando a matriz de correlação com o pacote corrplot
corrplot(correlation_matrix, method = "circle", type = "lower", tl.cex = 0.8, 
         title = "Matriz de Correlação", mar = c(0, 0, 1, 0))

# 4. Classificação - Usando k-NN (K-Nearest Neighbors)
# Função para treinar e avaliar o modelo k-NN
train_knn_model <- function(data, target, p = 0.7, k = 3) {
  set.seed(123)  # Para reprodutibilidade
  trainIndex <- createDataPartition(data[[target]], p = p, list = FALSE)
  trainData <- data[trainIndex, ]
  testData <- data[-trainIndex, ]
  
  # Aplicando o método k-NN
  knn_model <- train(as.formula(paste(target, "~ ."), data = trainData, method = "knn", tuneGrid = data.frame(k = k))
  
  # Previsões com o modelo treinado
  knn_predictions <- predict(knn_model, newdata = testData)
  
  # Avaliando a acurácia do modelo
  confusion_matrix <- confusionMatrix(knn_predictions, testData[[target]])
  print(confusion_matrix)
  
  # Retornar o modelo e as previsões
  return(list(model = knn_model, predictions = knn_predictions, testData = testData))
}

# Treinar e avaliar o modelo k-NN
knn_results <- train_knn_model(iris, "Species", p = 0.7, k = 3)

# 5. Visualizações adicionais
# Gráfico de dispersão com a previsão do modelo
ggplot(knn_results$testData, aes(x = Sepal.Length, y = Sepal.Width, color = knn_results$predictions)) +
  geom_point(alpha = 0.7) +
  labs(title = "Classificação: Previsão de Espécies pelo Modelo k-NN", x = "Sepal Length", y = "Sepal Width") +
  theme_minimal()

# 6. Validação Cruzada
# Usando validação cruzada para melhorar a avaliação do modelo
ctrl <- trainControl(method = "cv", number = 10)
knn_cv_model <- train(Species ~ ., data = iris, method = "knn", trControl = ctrl, tuneGrid = data.frame(k = 3))
print(knn_cv_model)