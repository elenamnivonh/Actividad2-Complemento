
%---------Identificación de Nulos---------%
%Identificamos la matriz de datos faltantes del DataFrame
nulos= ismissing(listings);
%Identificamos la cantidad de datos faltantes por Columna
nuloscolumna= sum(nulos);
%Identificamos la cantidad de datos faltantes por DataFrame
totalnulos= sum(nuloscolumna);


%------El total de los valores nulos de todo el dataframe = 65879--------%

%---------Sustitución de Nulos---------%

%Rellenamos datos faltantes por DataFrame usando diferentes métodos
DataFrame1 = fillmissing(listings,'previous','DataVariables',{'host_location','host_response_time','host_neighbourhood','neighbourhood','bathrooms_text','first_review','last_review','bedrooms','minimum_nights_avg_ntm'});
DataFrame2 = fillmissing(DataFrame1,'movmean', 2000,'DataVariables',{'host_response_rate','beds','minimum_minimum_nights','maximum_minimum_nights','minimum_maximum_nights','minimum_nights_avg_ntm','maximum_nights_avg_ntm','review_scores_rating','review_scores_accuracy','review_scores_cleanliness','review_scores_checkin','review_scores_communication','review_scores_location','review_scores_value','reviews_per_month','host_acceptance_rate'});
DataFrame3 = fillmissing(DataFrame2,'next','DataVariables',{'last_review','first_review','minimum_nights_avg_ntm','neighbourhood','host_neighbourhood','minimum_nights_avg_ntm','maximum_maximum_nights'});


%-------Comprobacion Valores Nulos---------%

nulos2= ismissing(DataFrame3);
%Identificamos la cantidad de datos faltantes por Columna
nuloscolumna2= sum(nulos2);
%Identificamos la cantidad de datos faltantes por DataFrame
totalnulos2= sum(nuloscolumna2);


%---------Identificación de Outliers---------

%Identificamos Matriz de outliers mediante método de quartiles
Outliers1 = isoutlier(DataFrame3,'quartiles','DataVariables',{'latitude','longitude','accommodates','bedrooms','beds','price','minimum_nights','maximum_nights','availability_30','availability_60','availability_90','availability_365','number_of_reviews','number_of_reviews_ltm','review_scores_rating','review_scores_accuracy','review_scores_cleanliness','review_scores_checkin','review_scores_location','calculated_host_listings_count','reviews_per_month'});

%Identificamos la cantidad de outliers por Columna
Column_outliers1= sum(Outliers1);

%Identificamos la cantidad de datos faltantes por DataFrame
DataFrame_outliers_quartiles= sum(Column_outliers1);

%Identificamos Matriz de outliers mediante método de grubbs
Outliers2 = isoutlier(DataFrame3,'grubbs','DataVariables',{'latitude','longitude','accommodates','bedrooms','beds','price','minimum_nights','maximum_nights','availability_30','availability_60','availability_90','availability_365','number_of_reviews','number_of_reviews_ltm','review_scores_rating','review_scores_accuracy','review_scores_cleanliness','review_scores_checkin','review_scores_location','calculated_host_listings_count','reviews_per_month'});

%Identificamos la cantidad de outliers por Columna
Column_outliers2= sum(Outliers2);

%Identificamos la cantidad de datos faltantes por DataFrame
DataFrame_outliers_grubbs= sum(Column_outliers2);

%Identificamos Matriz de outliers mediante método de desviación estándar
Outliers3 = isoutlier(DataFrame3,'mean','DataVariables',{'latitude','longitude','accommodates','bedrooms','beds','price','minimum_nights','maximum_nights','availability_30','availability_60','availability_90','availability_365','number_of_reviews','number_of_reviews_ltm','review_scores_rating','review_scores_accuracy','review_scores_cleanliness','review_scores_checkin','review_scores_location','calculated_host_listings_count','reviews_per_month'});

%Identificamos la cantidad de outliers por Columna
Column_outliers3= sum(Outliers3);

%Identificamos la cantidad de datos faltantes por DataFrame
DataFrame_outliers_desviacion= sum(Column_outliers3);


%---------Sustitución de Outliers---------

%Rellenamos Outliers DataFrame
DataFrameO= fillmissing(DataFrame2,'previous','DataVariables',{'latitude','longitude','accommodates','bathrooms_text','bedrooms','beds','price','minimum_nights','maximum_nights','availability_30','availability_60','availability_90','availability_365','number_of_reviews','number_of_reviews_ltm','review_scores_rating','review_scores_accuracy','review_scores_cleanliness','review_scores_checkin','review_scores_location','calculated_host_listings_count','reviews_per_month','minimum_minimum_nights','maximum_minimum_nights','minimum_nights_avg_ntm','host_neighbourhood','neighbourhood'});
DataFrameoki = fillmissing(DataFrameO,'movmean', 2000,'DataVariables',{'maximum_maximum_nights'});
DataFrameOk= fillmissing(DataFrameoki,'next','DataVariables',{'host_neighbourhood','neighbourhood','minimum_nights_avg_ntm','review_scores_cleanliness','review_scores_checkin','last_review','review_scores_rating','minimum_nights_avg_ntm','first_review','minimum_nights_avg_ntm'});

%---------Identificación de Nulos 3 ---------%

%Identificamos la matriz de datos faltantes del DataFrame
null3= ismissing(DataFrameOk);

%Identificamos la cantidad de datos faltantes por Columna
Columnnull3 = sum(null3);

%Identificamos la cantidad de datos faltantes por DataFrame
totalNull3= sum(Columnnull3);


%--------Filtro de datos----------------%

%Selecionamos solo las columnas que necesitamos para hacer el analisis

Filtromx= DataFrameOk(:,[16,17,22,30,31,34,37,38,40,41,42,51,52,53,56,66,74]);

%------Correlaciones--------%

%Matriz de correlaciones del Dataframe
Matriz=table2array(Filtromx); 
Mat_Corr=corrcoef(Matriz) 

%Mapa de calor
figure(1)
h = heatmap(Mat_Corr)


%---------Regresión lineal-------------

%Variables con mayor correlacion
%  availability_30 - availability_90 = 0.93
% bedroom - beds =0.745
% number_of_reviews - reviews_per_month = 0.54

%Graficos de dispersión de price con variables

%price y minimum_nights
figure(2)
S1 = scatter(Filtromx,'price','bedrooms');

%price y number_of_reviews
figure(3)
S2 = scatter(Filtromx,'price','number_of_reviews');

%price y reviews_per_month
figure(4)
S3 = scatter(Filtromx,'price','beds');


%Variable reviews_per_month
x1=Matriz(:,17);
%Variable bedrooms
x2=Matriz(:,7);
%Variable price
y=Matriz(:,9);
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


%Scatter plot de 3 variables con nuestro modelo predecido
figure(5)
scatter3(x1,x2,y,'filled');
hold on;
x1fit = min(x1):0.5:max(x1);
x2fit = min(x2):0.5:max(x2);
[X1FIT,X2FIT] = meshgrid(x1fit,x2fit);
YFIT = b(1)*X1FIT + b(2)*X2FIT;
mesh(X1FIT,X2FIT,YFIT);
xlabel('reviews_per_month');
ylabel('bedrooms');
zlabel('price');
view(30,10);
hold off

%------VISUALIZACION-------%

%Geobubble: Visualiza valores de datos en ubicaciones geográficas específicas

%Mapa de price por tipo de cuarto
figure(6)
geobubble(DataFrameOk,'latitude','longitude','SizeVariable','price','ColorVariable','room_type','Basemap','streets')
title 'Mexico precios por tipo de cuarto'

%Mapa de precios por baños 
geobubble(DataFrameOk,'latitude','longitude','SizeVariable','price','ColorVariable','bathrooms_text','Basemap','streets')
title 'Mexico precios por baños '

%Mapa de accommodates por tipo de cuarto
figure(7)
geobubble(DataFrameOk,'latitude','longitude','SizeVariable','accommodates','ColorVariable','room_type','Basemap','streets')
title 'Mexico accomodates vs room_type'

%Mapa de price por property_type
figure(8)
geobubble(DataFrameOk,'latitude','longitude','SizeVariable','price','ColorVariable','property_type','Basemap','streets')
title 'Mexico price vs property_type'

%Precio real
figure(9)
geobubble(DataFrameOk,'latitude','longitude','SizeVariable','price','ColorVariable','room_type','Basemap','streets')
title 'Mexico - Precio real vs room type';

figure(10)
Bris_Vars= DataFrameOk(:,[40,33])
parallelplot(Bris_Vars,'GroupVariable','room_type')
title 'Mexico room type -price';

%Price vs minimum_nights
ba_vars= data_final(:,[42,43]);
figure(11)
parallelplot(ba_vars,'GroupVariable','minimum_nights')
title 'Mexico Price Vs minimum nights'
