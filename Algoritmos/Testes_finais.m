%% Obtem todos os valores de todas as embarca��es da pasta com apenas as embarca��es selecionadas
%Obtem a Length width stdev mean e Number of scatters

 clear; clc;

Threshold = 0.6 % Treshold da fun��o de binariza��o da imagem SAR CFAR
%Threshold = 1/100 % Treshold da fun��o de binariza��o da imagem SAR TH
binaryzationType = 0; %0- CFAR 1- TH

root_folder = 'C:\Users\alvar\OneDrive\Ambiente de Trabalho\Mega ISEL\2_ano_MESTRADO\Tese\DataSet\Selected_files'; % replace with the actual path to the root folder

% Obter lenght e width calculadas de embarca��o

    file_list = dir(root_folder);
    file_list = file_list(~[file_list.isdir]); 
    file_names = {file_list.name}';   
    VALC = [];
    
% Adiciona o tipo da embarca��o e obtem todos os parametros necessarios
% para a sua classifica��o
    for j = 1:length(file_list)  
        aux = strsplit(file_names{j}, '_');
        switch aux{1}
            case 'Cargo'
                type = 1;
            case 'Fishing'
                type = 2;
            case 'Tanker'
                type = 3;
        end
    
        x = str2double(regexp(aux{2}, '\d+', 'match'));
        aux = strsplit(aux{3}, ',');
        y = str2double(regexp(aux{1}, '\d+', 'match'));

        imgpath = [file_list(j).folder '\' file_list(j).name];
        [dimension, stdev, mean, bimodalityF, bimodalityC] = Clengthwidth(imgpath,Threshold,binaryzationType);
        auxi = [type;x;y;dimension;stdev;mean;bimodalityF;bimodalityC];
        VALC = [VALC,auxi];
        disp(fprintf('Acabei figura %d! B %d',j,bimodalityF));
    end

%% SECUND�RIO! TESTES Transformar dados para colocar na rede neuronal (Exemplo com M�DIA) 
j=1
T = [];
X = [];
for i = 1:length(VALC)
    
    switch VALC(1,i)
        case 1                          %Cargo
             T(1:3,j) = [1 ; 0; 0]; 
        case 2                          %Fishing
             T(1:3,j) = [0 ; 0; 1];
        case 3                          %Tanker
             T(1:3,j) = [0 ; 1; 0];    
    end
    if VALC(5,i) == 0                       %Caso o valor de Width_AL seja 0 utiliza-se a Width_PROPS
        X(1:4,j) = [(VALC(4,i));(VALC(7,i));VALC(8,i);VALC(9,i)];   %Length_Al; Width_PROPS; stdev; mean;
    else                                    %Qualquer outro caso usa Width_Al
        X(1:4,j) = [(VALC(4,i));(VALC(5,i));VALC(8,i);VALC(9,i)];   %Length_Al; Width_Al; stdev; mean;
    end
    j = j + 1;
end

%% SECUND�RIO! TESTES Transformar dados para colocar na rede neuronal (Exemplo com numero de scatters)
j=1
T = [];
X = [];
for i = 1:length(VALC)
    
    switch VALC(1,i)
        case 1                          %Cargo
             T(1:3,j) = [1 ; 0; 0]; 
        case 2                          %Fishing
             T(1:3,j) = [0 ; 0; 1];
        case 3                          %Tanker
             T(1:3,j) = [0 ; 1; 0];    
    end
    if VALC(5,i) == 0                       %Caso o valor de Width_AL seja 0 utiliza-se a Width_PROPS
        X(1:4,j) = [(VALC(4,i));(VALC(7,i));VALC(8,i);VALC(11,i)];   %Length_Al; Width_PROPS; stdev; mean;
    else                                    %Qualquer outro caso usa Width_Al
        X(1:4,j) = [(VALC(4,i));(VALC(5,i));VALC(8,i);VALC(11,i)];   %Length_Al; Width_Al; stdev; mean;
    end
    j = j + 1;
end

%% PRINCIPAL! FINAL Transformar dados para colocar na rede neuronal (Exemplo com Number of Scatters e media)
% Neste caso a m�dia � colocada no array para ser utilizada na segunda rede
% neuronal
j=1;
T = [];
X = [];

% Criar matriz de Verifica��o
for i = 1:length(VALC)
    
    switch VALC(1,i)
        case 1                          %Cargo
             T(1:3,j) = [1 ; 0; 0]; 
        case 2                          %Fishing
             T(1:3,j) = [0 ; 0; 1];
        case 3                          %Tanker
             T(1:3,j) = [0 ; 1; 0];    
    end
    % Criar a matriz de entrada da Rede
    if VALC(5,i) == 0                       %Caso o valor de Width_AL seja 0 utiliza-se a Width_PROPS
        X(1:5,j) = [(VALC(4,i));(VALC(7,i));VALC(8,i);VALC(11,i);VALC(9,i)];   %Length_Al; Width_PROPS; stdev; mean;
    else                                    %Qualquer outro caso usa Width_Al
        X(1:5,j) = [(VALC(4,i));(VALC(5,i));VALC(8,i);VALC(11,i);VALC(9,i)];   %Length_Al; Width_Al; stdev;Bimodality; mean;
    end
    j = j + 1;
end

%% Criar primeira rede neuronal para classificar os tr�s tipos de embarca��es
% adicionar fator random aos dados
% � utilizado a mesma seed porque a correspondecia dos dados � relevante.
% � importante ser mensionado que como � feito a randomiza��o dos dados 
% cada itera��o produz resultados diferentes
 P = randperm(360); %% Random deve estar antes de escolher os barcos
 X = X(:,P);
 T = T(:,P);
% Retirar valores NaN adicionados pela fun�ao de bimodalidade
% Estes valores aparecem devido ao facto de que na equa��o do coeficiente
% de bimodalidade o denominador pode por vezes ser 0 criando um erro nos
% dados (numero de pixeis (N) muito pequeno)

 for i = 1:size(X,2) 
     if isnan(X(4,i))
         X(4,i) = 0;
     end
 end

 % Iniciar a rede
 set(gcf, 'Color', 'w');
 net = patternnet([4]); %rede para detetatar padr�es com 3 layers
 net = train(net,X(1:4,:),T); %treinar
 set(gcf, 'Color', 'w');
 Y = net(X(1:4,:)); %coeficientes
 plotconfusion(T,Y);


%% Depois da primeira fase de classifica��o passa-se para a segunda
% Nesta fase � verificado se a embarca��o foi classificada como fishing e
% retira-se essa coluna dos valores que ser�o inseridos na classifica��o de
% Tanker e Cargo
columnsToKeep = Y(3, :) <1/2;
Y = Y(:, columnsToKeep);
X = X(:, columnsToKeep);
T = T(:, columnsToKeep);
T = T(1:2,:);

%% Treinar a segunda rede neuronal para classifica��o de CARGO E TANKER vessels
% adicionar fator random aos dados
% � utilizado a mesma seed porque a correspondecia dos dados � relevante.
% � importante ser mensionado que como � feito a randomiza��o dos dados 
% cada itera��o produz resultados diferentes
 P = randperm(size(X,2)); %% Random deve estar antes de escolher os barcos
 X = X(:,P);
 T = T(:,P);
 set(gcf, 'Color', 'w');
 % Iniciar a rede
 net = patternnet([5]); %rede para detetatar padr�es com 3 layers
 [net, ept] = train(net,X,T); %treinar
 Y = net(X); %coeficientes
 %treino sem m�dia
%  [net, ept] = train(net,X(1:4,:),T); %treinar
%  Y = net(X(1:4,:)); %coeficientes
 plotconfusion(T,Y);  
 



 
 