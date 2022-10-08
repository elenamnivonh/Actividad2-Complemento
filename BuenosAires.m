
%---------Identificación de Nulos---------%
%Identificamos la matriz de datos faltantes del DataFrame
nulos= ismissing(buenosaires);
%Identificamos la cantidad de datos faltantes por Columna
nuloscolumna= sum(nulos);
%Identificamos la cantidad de datos faltantes por DataFrame
totalnulos= sum(nuloscolumna);

%------El total de los valores nulos de todo el dataframe = 72929--------%

%---------Sustitución de Nulos---------%

%Rellenamos datos faltantes por DataFrame usando diferentes métodos
DataFrame1 = fillmissing(buenosaires,'previous','DataVariables',{'host_location','host_neighbourhood','neighbourhood','first_review','last_review'});
DataFrame2 = fillmissing(DataFrame1,'movmean', 2000,'DataVariables',{'host_response_rate','host_acceptance_rate','bathrooms_text','bedrooms','beds','review_scores_rating','review_scores_accuracy','review_scores_cleanliness','review_scores_checkin','review_scores_communication','review_scores_location','review_scores_value','license','reviews_per_month'});

%-------Comprobacion Valores Nulos---------%
nulos2= ismissing(DataFrame2);
%Identificamos la cantidad de datos faltantes por Columna
nuloscolumna2= sum(nulos2);
%Identificamos la cantidad de datos faltantes por DataFrame
totalnulos2= sum(nuloscolumna2);

%---------Identificación de Outliers---------
%Identificamos Matriz de outliers mediante método de quartiles
Outliers1 = isoutlier(DataFrame2,'quartiles','DataVariables',{'latitude','longitude','accommodates','bathrooms_text','bedrooms','beds','price','minimum_nights','maximum_nights','availability_30','availability_60','availability_90','availability_365','number_of_reviews','number_of_reviews_ltm','review_scores_rating','review_scores_accuracy','review_scores_cleanliness','review_scores_checkin','review_scores_location','calculated_host_listings_count','reviews_per_month'});

%Identificamos la cantidad de outliers por Columna
Column_outliers1= sum(Outliers1);

%Identificamos la cantidad de datos faltantes por DataFrame
DataFrame_outliers_quartiles= sum(Column_outliers1);

%Identificamos Matriz de outliers mediante método de grubbs
Outliers2 = isoutlier(DataFrame2,'grubbs','DataVariables',{'latitude','longitude','accommodates','bathrooms_text','bedrooms','beds','price','minimum_nights','maximum_nights','availability_30','availability_60','availability_90','availability_365','number_of_reviews','number_of_reviews_ltm','review_scores_rating','review_scores_accuracy','review_scores_cleanliness','review_scores_checkin','review_scores_location','calculated_host_listings_count','reviews_per_month'});

%Identificamos la cantidad de outliers por Columna
Column_outliers2= sum(Outliers2);

%Identificamos la cantidad de datos faltantes por DataFrame
DataFrame_outliers_grubbs= sum(Column_outliers2);

%Identificamos Matriz de outliers mediante método de desviación estándar
Outliers3 = isoutlier(DataFrame2,'mean','DataVariables',{'latitude','longitude','accommodates','bathrooms_text','bedrooms','beds','price','minimum_nights','maximum_nights','availability_30','availability_60','availability_90','availability_365','number_of_reviews','number_of_reviews_ltm','review_scores_rating','review_scores_accuracy','review_scores_cleanliness','review_scores_checkin','review_scores_location','calculated_host_listings_count','reviews_per_month'});

%Identificamos la cantidad de outliers por Columna
Column_outliers3= sum(Outliers3);

%Identificamos la cantidad de datos faltantes por DataFrame
DataFrame_outliers_desviacion= sum(Column_outliers3);


%---------Sustitución de Outliers---------

%Rellenamos Outliers DataFrame
DataFrameOk= fillmissing(DataFrame2,'previous','DataVariables',{'latitude','longitude','accommodates','bathrooms_text','bedrooms','beds','price','minimum_nights','maximum_nights','availability_30','availability_60','availability_90','availability_365','number_of_reviews','number_of_reviews_ltm','review_scores_rating','review_scores_accuracy','review_scores_cleanliness','review_scores_checkin','review_scores_location','calculated_host_listings_count','reviews_per_month'});

%---------Identificación de Nulos 3 ---------%

%Identificamos la matriz de datos faltantes del DataFrame
null3= ismissing(DataFrameOk);

%Identificamos la cantidad de datos faltantes por Columna
Columnnull3 = sum(null3);

%Identificamos la cantidad de datos faltantes por DataFrame
totalNull3= sum(Columnnull3);


%--------Filtro de datos----------------%

%Selecionamos solo las columnas que necesitamos para hacer el analisis

Filtroba= DataFrameOk(:,[31,32,35,37,38,39,41,42,43,57,65,67,71,74]);

%------Correlaciones--------%

Matriz=table2array(Filtroba); 
Mat_Corr = corrcoef(Matriz);

%Mapa de calor
figure(1)
h = heatmap(Mat_Corr)

%---------Regresión lineal-------------
%Variables con mayor correlacion
%  accommodates - beds = 0.72
% bedrooms - accommodates =0.62
% review_scores_checkin - review_scores_location = 0.59

%Variable accommodates
x1=Matriz(:,3);
%Variable bedrooms
x2=Matriz(:,5);
%Variable price
y=Matriz(:,7);
%Variables independientes
X= [x1 x2];
%Variable dependiente
y= [y];
[b,~,~,~,stats] = regress(y,X);

%---------Predicción----------------
%Calcular predicción de columna total
total_Pred= b(1)*x1 + b(2)*x2;
%Agregar columna a tabla
data_final= addvars(DataFrameOk,total_Pred,'Before',"price");

%---------Visualización-------------
%Scatter plot de 3 variables con nuestro modelo predecido
figure(2)
scatter3(x1,x2,y,'filled');
hold on;
x1fit = min(x1):0.5:max(x1);
x2fit = min(x2):0.5:max(x2);
[X1FIT,X2FIT] = meshgrid(x1fit,x2fit);
YFIT = b(1)*X1FIT + b(2)*X2FIT;
mesh(X1FIT,X2FIT,YFIT);
xlabel('review_scores_rating');
ylabel('host_acceptance_rate');
zlabel('price');
view(30,10);
hold off

%Mapa de review_scores_rating por tipo de cuarto
figure(3)
geobubble(data_final,'latitude','longitude','SizeVariable','review_scores_rating','ColorVariable','room_type','Basemap','streets')
title 'Buenos Aires'

%Mapa de precios por tipo de cuarto
figure(4)
geobubble(data_final,'latitude','longitude','SizeVariable','price','ColorVariable','room_type','Basemap','streets')
title 'Buenos Aires Precios por tipo de cuarto'

%Price vs accommodates
ba_vars= data_final(:,[42,35]);
figure(5)
parallelplot(ba_vars,'GroupVariable','accommodates')
title 'Buenos Aires Price Vs accommodates'

%Price vs minimum_nights
ba_vars= data_final(:,[42,43]);
figure(6)
parallelplot(ba_vars,'GroupVariable','minimum_nights')
title 'Buenos Aires Price Vs minimum nights'
